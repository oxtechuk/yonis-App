import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/app/di/dependency_injection.dart';
import 'package:younis_app/features/home/data/models/doctors_dto.dart';
import 'package:younis_app/features/home/data/repositories/doctors_repository_impl.dart';
import 'package:younis_app/features/home/data/sources/doctors_remote_data_source.dart';
import 'package:younis_app/features/home/domain/use_cases/get_doctors_use_case.dart';
import 'package:younis_app/features/home/presentation/cubit/doctors_cubit.dart';
import 'package:younis_app/features/home/presentation/widgets/book_service_bottom_sheet.dart';
import 'package:younis_app/features/services/presentation/pages/doctor_selection_page.dart';
import 'package:younis_app/features/services/presentation/widgets/doctor_card.dart';

import '../../support/pump_app.dart';

class _FakeDoctorsRemoteDataSource implements DoctorsRemoteDataSource {
  const _FakeDoctorsRemoteDataSource(this.response);

  final DoctorsResponseDto response;

  @override
  Future<DoctorsResponseDto> getDoctors() async => response;
}

void _registerFakeDoctors(DoctorsResponseDto response) {
  final dataSource = _FakeDoctorsRemoteDataSource(response);
  final repo = DoctorsRepositoryImpl(remoteDataSource: dataSource);
  final useCase = GetDoctorsUseCase(repo);
  getIt
    ..registerLazySingleton<DoctorsRemoteDataSource>(() => dataSource)
    ..registerLazySingleton<GetDoctorsUseCase>(() => useCase)
    ..registerLazySingleton<DoctorsCubit>(
      () => DoctorsCubit(getDoctorsUseCase: useCase),
    );
}

void main() {
  const multiDoctorPayload = <String, dynamic>{
    'success': true,
    'is_single_doctor': false,
    'auto_selected_doctor': null,
    'total': 2,
    'doctors': [
      {
        'id': 2,
        'name': 'أ/احمد جابر ابراهيم',
        'name_en': 'M/Ahmed gaber',
        'title': 'اخصئي نفس',
        'title_en': null,
        'specialty': 'اخصئي نفس',
        'specialty_en': null,
        'avatar_url':
            'https://younis-almurshid.com/storage/doctors/doctor_1792174887_Zubu5OoL.jpg',
        'bio': null,
        'bio_en': null,
        'phone': '+201278329405',
        'email': null,
        'experience_years': 5,
        'consultation_fee': 10,
      },
      {
        'id': 1,
        'name': 'د. يونس المرشدي',
        'name_en': 'Dr. Younis Al-Murshedi',
        'title':
            'المعالج  النفسي يونس المرشد - استشاري العلاج النفسي والسلوكي والطب النفسي',
        'title_en':
            'Dr. Younis Al-Murshedi - Consultant Clinical Psychologist & Psychotherapist',
        'specialty': 'العلاج النفسي والسلوكي',
        'specialty_en': 'Psychotherapy & Behavioral Therapy',
        'avatar_url':
            'https://younis-almurshid.com/storage/branding/DbQiJBj3VcQ0zsEvNfOgracbgvzNYwikCm85XsMe.png',
        'bio':
            'المعالج النفسي يونس المرشد استشاري العلاج النفسي والسلوكي مع خبرة متميزة في معالجة اضطرابات القلق، الاكتئاب، نوبات الهلع، والصدمات النفسية.',
        'bio_en':
            'Younis Al-Murshedi is a licensed Consultant Psychotherapist.',
        'phone': '+9647800000000',
        'email': 'dr.yonis@example.com',
        'experience_years': 12,
        'consultation_fee': 50,
      },
    ],
  };

  test('DoctorsResponseDto parses /api/doctors payload accurately', () {
    final dto = DoctorsResponseDto.fromJson(multiDoctorPayload);
    final result = dto.toEntity();

    expect(result.isSingleDoctor, isFalse);
    expect(result.autoSelectedDoctor, isNull);
    expect(result.shouldSkipSelection, isFalse);
    expect(result.doctors, hasLength(2));

    final first = result.doctors[0];
    expect(first.id, 2);
    expect(first.name, 'أ/احمد جابر ابراهيم');
    expect(first.nameEn, 'M/Ahmed gaber');
    expect(first.specialty, 'اخصئي نفس');
    expect(first.experienceYears, 5);
    expect(first.consultationFee, 10);

    final second = result.doctors[1];
    expect(second.id, 1);
    expect(second.name, 'د. يونس المرشدي');
    expect(second.experienceYears, 12);
    expect(second.consultationFee, 50);
  });

  test(
    'DoctorsResult.shouldSkipSelection is true when single doctor or auto_selected_doctor has value',
    () {
      final singleDoctorDto = DoctorsResponseDto.fromJson({
        'success': true,
        'is_single_doctor': true,
        'auto_selected_doctor': multiDoctorPayload['doctors'] is List
            ? (multiDoctorPayload['doctors'] as List).first
            : null,
        'total': 1,
        'doctors': [(multiDoctorPayload['doctors'] as List).first],
      });
      final singleResult = singleDoctorDto.toEntity();
      expect(singleResult.shouldSkipSelection, isTrue);
      expect(singleResult.effectiveAutoSelectedDoctor?.id, 2);
    },
  );

  testWidgets(
    'Services tab requires selecting a doctor first when multiple doctors exist and none is selected',
    (tester) async {
      await pumpLocalizedApp(tester);
      _registerFakeDoctors(DoctorsResponseDto.fromJson(multiDoctorPayload));

      await enterMainApp(tester);

      // Navigate to Services tab
      await tester.tap(find.text('خدمتنا'));
      await tester.pumpAndSettle();

      // DoctorSelectionBody is shown before services
      expect(find.byType(DoctorSelectionBody), findsOneWidget);
      expect(find.byType(DoctorCard), findsNWidgets(2));
      expect(find.text('أ/احمد جابر ابراهيم'), findsOneWidget);
      expect(find.text('د. يونس المرشدي'), findsOneWidget);

      // Select a doctor
      await tester.tap(find.text('د. يونس المرشدي'));
      await tester.pumpAndSettle();

      // Now services view is shown and DoctorSelectionBody is gone
      expect(find.byType(DoctorSelectionBody), findsNothing);
      expect(find.text('تغيير الطبيب'), findsOneWidget);
    },
  );

  testWidgets(
    'Services tab skips doctor selection when only one doctor exists',
    (tester) async {
      await pumpLocalizedApp(tester);
      _registerFakeDoctors(
        DoctorsResponseDto.fromJson({
          'success': true,
          'is_single_doctor': true,
          'auto_selected_doctor': (multiDoctorPayload['doctors'] as List).last,
          'total': 1,
          'doctors': [(multiDoctorPayload['doctors'] as List).last],
        }),
      );

      await enterMainApp(tester);

      await tester.tap(find.text('خدمتنا'));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorSelectionBody), findsNothing);
    },
  );

  testWidgets(
    'DoctorSelectionPage selects a doctor and opens BookServiceBottomSheet without ProviderNotFoundException',
    (tester) async {
      await pumpLocalizedApp(tester);
      _registerFakeDoctors(DoctorsResponseDto.fromJson(multiDoctorPayload));

      await enterMainApp(tester);

      final homeContext = tester.element(find.text('الرئيسية'));
      BookServiceBottomSheet.show(homeContext);
      await tester.pumpAndSettle();

      // Pushed standalone DoctorSelectionPage
      expect(find.byType(DoctorSelectionPage), findsOneWidget);
      expect(find.byType(DoctorCard), findsNWidgets(2));

      // Tap a doctor on DoctorSelectionPage
      await tester.tap(find.text('د. يونس المرشدي'));
      await tester.pumpAndSettle();

      // DoctorSelectionPage popped and BookServiceBottomSheet opened
      expect(find.byType(DoctorSelectionPage), findsNothing);
      expect(find.byType(BookServiceBottomSheet), findsOneWidget);
    },
  );
}
