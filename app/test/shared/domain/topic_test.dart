import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/core/errors/failure.dart';
import 'package:teleios/shared/domain/entities/dimension.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';
import 'package:teleios/shared/domain/entities/topic.dart';

Topic topic(TopicStatus status) => Topic(
  id: 't1',
  name: 'Proteger mi patrimonio',
  dimensionId: Dimension.vidaPractica,
  status: status,
  origin: TopicOrigin.usuario,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  const prov = PassageRef(bookCode: 'PRO', chapter: 22, verseStart: 7);
  final at = DateTime(2026, 10, 27);

  group('cleanName', () {
    test('recorta espacios y capitaliza', () => expect(Topic.cleanName('  dominio   propio '), 'Dominio propio'));
    test('rechaza vacío', () => expect(() => Topic.cleanName('   '), throwsA(isA<ValidationFailure>())));
    test('rechaza > 60 caracteres', () => expect(() => Topic.cleanName('a' * 61), throwsA(isA<ValidationFailure>())));
  });

  group('transiciones de estado', () {
    test('incubación → validado guarda el pasaje', () {
      final v = topic(TopicStatus.incubacion).validate(prov, at: at);
      expect(v.status, TopicStatus.validado);
      expect(v.validationPassage, prov);
      expect(v.updatedAt, at);
    });

    test('sombra → validado está permitido', () {
      expect(topic(TopicStatus.sombra).validate(prov, at: at).status, TopicStatus.validado);
    });

    test('no se valida dos veces ni se valida un refutado', () {
      expect(() => topic(TopicStatus.validado).validate(prov, at: at), throwsA(isA<ValidationFailure>()));
      expect(() => topic(TopicStatus.refutado).validate(prov, at: at), throwsA(isA<ValidationFailure>()));
    });

    test('refutar exige motivo y solo desde incubación', () {
      expect(() => topic(TopicStatus.incubacion).refute(reason: ' ', at: at), throwsA(isA<ValidationFailure>()));
      expect(() => topic(TopicStatus.validado).refute(reason: 'x', at: at), throwsA(isA<ValidationFailure>()));
      final r = topic(TopicStatus.incubacion).refute(reason: ' Contradice Lc 6:35 ', at: at);
      expect(r.status, TopicStatus.refutado);
      expect(r.note, 'Contradice Lc 6:35');
    });

    test('reabrir un refutado vuelve a incubación y limpia el pasaje', () {
      final refuted = topic(TopicStatus.incubacion).refute(reason: 'x', passage: prov, at: at);
      final reopened = refuted.reopen(at: at);
      expect(reopened.status, TopicStatus.incubacion);
      expect(reopened.validationPassage, isNull);
    });
  });
}
