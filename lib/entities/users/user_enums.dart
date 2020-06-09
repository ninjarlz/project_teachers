enum UserType { COACH, EXPERT }

extension UserTypeExtension on UserType {
  String get label {
    switch (this) {
      case UserType.COACH:
        return 'Coach';
      case UserType.EXPERT:
        return 'Expert';
      default:
        return null;
    }
  }

  static UserType getValue(String label) {
    switch (label) {
      case "Coach":
        return UserType.COACH;
      case "Expert":
        return UserType.EXPERT;
      default:
        return null;
    }
  }

  static List<String> get labels {
    List<String> labels = List<String>();
    UserType.values.forEach((value) {
      labels.add(value.label);
    });
    return labels;
  }

  static List<UserType> getValuesFromLabels(List<String> labels) {
    return labels.map((label) {
      return getValue(label);
    }).toList();
  }

}

enum CoachType { PRO_ACTIVE, VIDEO, INTERPERSONAL_RELATIONS }

extension CoachTypeExtension on CoachType {
  String get label {
    switch (this) {
      case CoachType.PRO_ACTIVE:
        return 'pro_active';
      case CoachType.VIDEO:
        return 'video';
      case CoachType.INTERPERSONAL_RELATIONS:
        return 'interpersonal_relations';
      default:
        return null;
    }
  }

  static List<String> get labels {
    List<String> labels = List<String>();
    CoachType.values.forEach((value) {
      labels.add(value.label);
    });
    return labels;
  }

  static CoachType getValue(String label) {
    switch (label) {
      case "pro_active":
        return CoachType.PRO_ACTIVE;
      case "video":
        return CoachType.VIDEO;
      case "interpersonal_relations":
        return CoachType.INTERPERSONAL_RELATIONS;
      default:
        return null;
    }
  }

  static List<CoachType> getValuesFromLabels(List<String> labels) {
    return labels.map((label) {
      return getValue(label);
    }).toList();
  }
}

enum SchoolSubject { NONE, MATHS, ENGLISH, PHYSICS, CHEMISTRY, IT }

extension SchoolSubjectExtension on SchoolSubject {
  String get label {
    switch (this) {
      case SchoolSubject.NONE:
        return 'none';
      case SchoolSubject.ENGLISH:
        return 'english';
      case SchoolSubject.MATHS:
        return 'maths';
      case SchoolSubject.PHYSICS:
        return 'physics';
      case SchoolSubject.CHEMISTRY:
        return 'chemistry';
      case SchoolSubject.IT:
        return 'it';
      default:
        return null;
    }
  }

  static List<String> get labels {
    List<String> labels = List<String>();
    SchoolSubject.values.forEach((value) {
      labels.add(value.label);
    });
    return labels;
  }

  static List<String> get editableLabels {
    List<String> labels = List<String>();
    for (int i = 1; i < SchoolSubject.values.length; i++) {
      labels.add(SchoolSubject.values[i].label);
    }
    return labels;
  }

  static SchoolSubject getValue(String label) {
    switch (label) {
      case "none":
        return SchoolSubject.NONE;
      case "english":
        return SchoolSubject.ENGLISH;
      case "maths":
        return SchoolSubject.MATHS;
      case 'physics':
        return SchoolSubject.PHYSICS;
      case 'chemistry':
        return SchoolSubject.CHEMISTRY;
      case 'it':
        return SchoolSubject.IT;
      default:
        return null;
    }
  }

  static List<String> getLabelsFromList(List<SchoolSubject> schoolSubjects) {
    List<String> subjectsLabels = List<String>();
    for (SchoolSubject schoolSubject in schoolSubjects) {
      subjectsLabels.add(schoolSubject.label);
    }
    return subjectsLabels;
  }


  static List<SchoolSubject> getValuesFromLabels(List<String> labels) {
    return labels.map((label) {
      return getValue(label);
    }).toList();
  }
}

enum Specialization {
  INTERPERSONAL_COMPETENCE,
  PEDAGOGICAL_COMPETENCE,
  SUBJECT_MATTER_DIDACTIC_COMPETENCE,
  ORGANISATIONAL_COMPETENCE,
  WORKING_TOGETHER_WITH_COLLEAGUES,
  WORKING_TOGETHER_WITH_THE_SURROUNDING_AREA,
  REFLECTION_AND_DEVELOPMENT,
  METROPOLITAN_CLASS_MANAGEMENT,
  MENTOR_COUNCIL,
  PERSONAL_DEVELOPMENT,
  IT
}

extension SpecializationExtension on Specialization {
  String get label {
    switch (this) {
      case Specialization.METROPOLITAN_CLASS_MANAGEMENT:
        return 'metropolitan_class_management';
      case Specialization.MENTOR_COUNCIL:
        return 'mentor_council';
      case Specialization.PERSONAL_DEVELOPMENT:
        return 'personal_development';
      case Specialization.IT:
        return 'it';
      case Specialization.INTERPERSONAL_COMPETENCE:
        return 'interpersonal_competence';
      case Specialization.PEDAGOGICAL_COMPETENCE:
        return 'pedagogical_competence';
      case Specialization.SUBJECT_MATTER_DIDACTIC_COMPETENCE:
        return 'subject_matter_didactic_competence';
      case Specialization.ORGANISATIONAL_COMPETENCE:
        return 'organisational_competence';
      case Specialization.WORKING_TOGETHER_WITH_COLLEAGUES:
        return 'working_together_with_colleagues';
      case Specialization.WORKING_TOGETHER_WITH_THE_SURROUNDING_AREA:
        return 'working_together_with_the_surrounding_area';
      case Specialization.REFLECTION_AND_DEVELOPMENT:
        return 'reflection_and_development';
      default:
        return null;
    }
  }

  static Specialization getValueFromLabel(String label) {
    switch (label) {
      case "metropolitan_class_management":
        return Specialization.METROPOLITAN_CLASS_MANAGEMENT;
      case "mentor_council":
        return Specialization.MENTOR_COUNCIL;
      case "personal_development":
        return Specialization.PERSONAL_DEVELOPMENT;
      case "interpersonal_competence":
        return Specialization.INTERPERSONAL_COMPETENCE;
      case "it":
        return Specialization.IT;
      case 'pedagogical_competence':
        return Specialization.PEDAGOGICAL_COMPETENCE;
      case 'subject_matter_didactic_competence':
        return Specialization.SUBJECT_MATTER_DIDACTIC_COMPETENCE;
      case 'organisational_competence':
        return Specialization.ORGANISATIONAL_COMPETENCE;
      case 'working_together_with_colleagues':
        return Specialization.WORKING_TOGETHER_WITH_COLLEAGUES;
      case 'working_together_with_the_surrounding_area':
        return Specialization.WORKING_TOGETHER_WITH_THE_SURROUNDING_AREA;
      case 'reflection_and_development':
        return Specialization.REFLECTION_AND_DEVELOPMENT;
      default:
        return null;
    }
  }

  static List<String> get labels {
    List<String> labels = List<String>();
    Specialization.values.forEach((value) {
      labels.add(value.label);
    });
    return labels;
  }

  String get shortcut {
    switch (this) {
      case Specialization.METROPOLITAN_CLASS_MANAGEMENT:
        return 'metropolitan_class_management_s';
      case Specialization.MENTOR_COUNCIL:
        return 'mentor_council_s';
      case Specialization.PERSONAL_DEVELOPMENT:
        return 'personal_development_s';
      case Specialization.IT:
        return 'it';
      case Specialization.INTERPERSONAL_COMPETENCE:
        return 'interpersonal_competence_s';
      case Specialization.PEDAGOGICAL_COMPETENCE:
        return 'pedagogical_competence_s';
      case Specialization.SUBJECT_MATTER_DIDACTIC_COMPETENCE:
        return 'subject_matter_didactic_competence_s';
      case Specialization.ORGANISATIONAL_COMPETENCE:
        return 'organisational_competence_s';
      case Specialization.WORKING_TOGETHER_WITH_COLLEAGUES:
        return 'working_together_with_colleagues_s';
      case Specialization.WORKING_TOGETHER_WITH_THE_SURROUNDING_AREA:
        return 'working_together_with_the_surrounding_area_s';
      case Specialization.REFLECTION_AND_DEVELOPMENT:
        return 'reflection_and_development_s';
      default:
        return null;
    }
  }

  static List<String> get shortcuts {
    List<String> shortcuts = List<String>();
    Specialization.values.forEach((value) {
      shortcuts.add(value.shortcut);
    });
    return shortcuts;
  }

  static List<Specialization> getValuesFromLabels(List<String> labels) {
    return labels.map((label) {
      return getValueFromLabel(label);
    }).toList();
  }

  static List<String> getLabelsFromList(
      List<Specialization> specializations) {
    List<String> specializationsLabels = List<String>();
    for (Specialization specialization in specializations) {
      specializationsLabels.add(specialization.label);
    }
    return specializationsLabels;
  }

  static List<String> getShortcutsFromList(
      List<Specialization> specializations) {
    List<String> specializationsShortcuts = List<String>();
    for (Specialization specialization in specializations) {
      specializationsShortcuts.add(specialization.shortcut);
    }
    return specializationsShortcuts;
  }
}
