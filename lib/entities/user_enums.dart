enum UserType {
  COACH, EXPERT
}

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

  static UserType getValue(String label){
    switch(label) {
      case "Coach":
        return UserType.COACH;
      case "Expert":
        return UserType.EXPERT;
      default:
        return null;
    }
  }
}

enum CoachType {
  PRO_ACTIVE, VIDEO, INTERPERSONAL_RELATIONS
}

extension CoachTypeExtension on CoachType {
  String get label {
    switch (this) {
      case CoachType.PRO_ACTIVE:
        return 'Pro-active';
      case CoachType.VIDEO:
        return 'Video';
      case CoachType.INTERPERSONAL_RELATIONS:
        return 'Interpersonal relations';
      default:
        return null;
    }
  }

  static CoachType getValue(String label){
    switch(label) {
      case "Pro-active":
        return CoachType.PRO_ACTIVE;
      case "Video":
        return CoachType.VIDEO;
      case "Interpersonal relations":
        return CoachType.INTERPERSONAL_RELATIONS;
      default:
        return null;
    }
  }
}

enum SchoolSubject {
  MATHS, ENGLISH
}

extension SchoolSubjectExtension on SchoolSubject {
  String get label {
    switch (this) {
      case SchoolSubject.ENGLISH:
        return 'English';
      case SchoolSubject.MATHS:
        return 'Maths';
      default:
        return null;
    }
  }

  static SchoolSubject getValue(String label){
    switch(label) {
      case "English":
        return SchoolSubject.ENGLISH;
      case "Maths":
        return SchoolSubject.MATHS;
      default:
        return null;
    }
  }
}

enum Specialization {
  EIGHT_BSL_SKILLS, GROOTSTEDELIJK_KLASSENMANAGEMENT, MENTORAAT,EIGENONTWIKKELING, IT
}

extension SpecializationExtension on Specialization {
  String get label {
    switch (this) {
      case Specialization.EIGHT_BSL_SKILLS:
        return '8 BSL Skills';
      case Specialization.GROOTSTEDELIJK_KLASSENMANAGEMENT:
        return 'Grootstedelijk Klassenmanagement';
      case Specialization.MENTORAAT:
        return 'Mentoraat';
      case Specialization.EIGENONTWIKKELING:
        return 'Eigenontwikkeling';
      case Specialization.IT:
        return 'IT';
      default:
        return null;
    }
  }

  static Specialization getValue(String label){
    switch(label) {
      case "8 BSL Skills":
        return Specialization.EIGHT_BSL_SKILLS;
      case "Grootstedelijk Klassenmanagement":
        return Specialization.GROOTSTEDELIJK_KLASSENMANAGEMENT;
      case "Mentoraat":
        return Specialization.MENTORAAT;
      case "Eigenontwikkeling":
        return Specialization.EIGENONTWIKKELING;
      case "IT":
        return Specialization.IT;
      default:
        return null;
    }
  }
}
