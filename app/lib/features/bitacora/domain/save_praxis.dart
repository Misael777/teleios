import '../../../core/errors/failure.dart';
import '../../../core/utils/ids.dart';
import '../../../shared/domain/entities/dimension.dart';
import '../../../shared/domain/entities/praxis_entry.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../../shared/domain/repositories/attachment_store.dart';
import '../../../shared/domain/repositories/topic_repository.dart';
import '../../../shared/domain/usecases/topic_usecases.dart';
import 'praxis.dart';
import 'repositories.dart';

/// Guarda un registro A-B-C con sus tópicos e imágenes.
///
/// Reglas:
/// - Un tópico nuevo creado aquí nace **en incubación** (no hay pasaje que lo ancle),
///   salvo que el registro cite un pasaje: entonces nace validado.
/// - Con filtro "cosmovisión", la creencia nombrada se crea o vincula en Incubación.
/// - Las imágenes se escriben antes de la transacción y se borran si esta falla.
class SavePraxis {
  SavePraxis({
    required PraxisRepository praxis,
    required TopicRepository topics,
    required AttachmentRepository attachments,
    required AttachmentStore store,
    required TransactionRunner transaction,
    Clock? clock,
  }) : _praxis = praxis,
       _attachments = attachments,
       _store = store,
       _transaction = transaction,
       _now = clock ?? DateTime.now,
       _resolve = ResolveTopicDraft(topics, clock: clock),
       _createIncubation = CreateIncubationTopic(CreateTopic(topics, clock: clock));

  final PraxisRepository _praxis;
  final AttachmentRepository _attachments;
  final AttachmentStore _store;
  final TransactionRunner _transaction;
  final Clock _now;
  final ResolveTopicDraft _resolve;
  final CreateIncubationTopic _createIncubation;

  static const maxTextLength = 5000;
  static const maxImages = 4;

  Future<String> call(PraxisDraft draft) async {
    _validate(draft);
    final id = draft.id ?? newId();
    final written = <Attachment>[];
    try {
      for (final image in draft.newImages) {
        final attachmentId = newId();
        final fileName = '$attachmentId.jpg.enc';
        await _store.write(fileName, image.bytes);
        written.add(
          Attachment(
            id: attachmentId,
            ownerType: Attachment.ownerPraxis,
            ownerId: id,
            fileName: fileName,
            mimeType: image.mimeType,
            sizeBytes: image.bytes.length,
            width: image.width,
            height: image.height,
            createdAt: _now(),
          ),
        );
      }

      final removedFiles = <String>[];
      await _transaction.run(() async {
        final statusForNew = draft.passage != null ? TopicStatus.validado : TopicStatus.incubacion;
        final topicIds = <String>{for (final t in draft.topics) (await _resolve(t, statusForNew: statusForNew)).id};
        final worldview = draft.worldview?.trim() ?? '';
        if (draft.filter == FilterType.cosmovision && worldview.isNotEmpty) {
          final topic = await _createIncubation(
            name: worldview,
            dimensionId: Dimension.vidaPractica,
            note: 'Registrada desde la Bitácora',
          );
          topicIds.add(topic.id);
        }

        await _praxis.upsert(
          PraxisEntry(
            id: id,
            date: draft.date,
            circumstance: draft.circumstance.trim(),
            emotionIds: draft.emotionIds.toSet().toList(),
            intensity: draft.intensity,
            filter: draft.filter,
            foundationDetail: _clean(draft.foundationDetail),
            passage: draft.passage,
            triggerIds: draft.triggerIds.toSet().toList(),
            topicIds: topicIds.toList(),
            action: draft.action.trim(),
            peace: draft.peace,
            coherence: draft.coherence,
          ),
        );
        for (final a in written) {
          await _attachments.add(a);
        }
        if (draft.removedAttachmentIds.isNotEmpty) {
          final existing = await _attachments.listFor(Attachment.ownerPraxis, id);
          for (final a in existing.where((a) => draft.removedAttachmentIds.contains(a.id))) {
            await _attachments.remove(a.id);
            removedFiles.add(a.fileName);
          }
        }
      });
      // Los archivos quitados se borran solo cuando la transacción ya se confirmó.
      for (final f in removedFiles) {
        await _store.delete(f);
      }
      return id;
    } catch (_) {
      for (final a in written) {
        await _store.delete(a.fileName);
      }
      rethrow;
    }
  }

  void _validate(PraxisDraft d) {
    if (d.circumstance.trim().isEmpty) throw const ValidationFailure('Describe brevemente qué pasó.');
    if (d.circumstance.length > maxTextLength || d.action.length > maxTextLength) {
      throw const ValidationFailure('El texto es demasiado largo (máx. 5.000 caracteres).');
    }
    if (d.emotionIds.isEmpty) throw const ValidationFailure('Elige al menos una emoción.');
    for (final (label, value) in [('intensidad', d.intensity), ('paz', d.peace), ('coherencia', d.coherence)]) {
      if (value != null && (value < 1 || value > 10)) {
        throw ValidationFailure('El valor de $label debe estar entre 1 y 10.');
      }
    }
    if (d.newImages.length > maxImages) throw const ValidationFailure('Máximo 4 imágenes por registro.');
  }

  static String? _clean(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
}

/// Borra un registro y sus imágenes.
class DeletePraxis {
  DeletePraxis({
    required PraxisRepository praxis,
    required AttachmentRepository attachments,
    required AttachmentStore store,
    required TransactionRunner transaction,
  }) : _praxis = praxis,
       _attachments = attachments,
       _store = store,
       _transaction = transaction;

  final PraxisRepository _praxis;
  final AttachmentRepository _attachments;
  final AttachmentStore _store;
  final TransactionRunner _transaction;

  Future<void> call(String id) async {
    final files = await _transaction.run(() async {
      final list = await _attachments.listFor(Attachment.ownerPraxis, id);
      for (final a in list) {
        await _attachments.remove(a.id);
      }
      await _praxis.delete(id);
      return list.map((a) => a.fileName).toList();
    });
    for (final f in files) {
      await _store.delete(f);
    }
  }
}
