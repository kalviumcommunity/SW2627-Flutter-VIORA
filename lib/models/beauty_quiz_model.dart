class QuizOption {
  final String id;
  final String title;
  final String description;
  final String icon;

  const QuizOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
      };
}

class QuizQuestion {
  final String id;
  final int stepNumber;
  final String category;
  final String title;
  final String subtitle;
  final bool isMultiSelect;
  final bool required;
  final List<QuizOption> options;

  const QuizQuestion({
    required this.id,
    required this.stepNumber,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.isMultiSelect,
    required this.required,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>? ?? [])
        .map((e) => QuizOption.fromJson(e as Map<String, dynamic>))
        .toList();
    return QuizQuestion(
      id: (json['id'] ?? '').toString(),
      stepNumber: (json['stepNumber'] as num?)?.toInt() ?? 1,
      category: (json['category'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      isMultiSelect: json['isMultiSelect'] as bool? ?? false,
      required: json['required'] as bool? ?? true,
      options: opts,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stepNumber': stepNumber,
        'category': category,
        'title': title,
        'subtitle': subtitle,
        'isMultiSelect': isMultiSelect,
        'required': required,
        'options': options.map((e) => e.toJson()).toList(),
      };
}

class QuizAnswers {
  String? hairType;
  List<String> hairConcerns;
  String? skinType;
  List<String> goals;
  List<String> sensitivities;

  QuizAnswers({
    this.hairType,
    List<String>? hairConcerns,
    this.skinType,
    List<String>? goals,
    List<String>? sensitivities,
  })  : hairConcerns = hairConcerns ?? [],
        goals = goals ?? [],
        sensitivities = sensitivities ?? [];

  void setSingleAnswer(String questionId, String optionId) {
    switch (questionId) {
      case 'hairType':
        hairType = optionId;
        break;
      case 'skinType':
        skinType = optionId;
        break;
    }
  }

  Map<String, dynamic> toBackendJson() => toJson();

  bool isStepAnswered(QuizQuestion question) {
    switch (question.id) {
      case 'hairType':
        return hairType != null && hairType!.trim().isNotEmpty;
      case 'hairConcerns':
        return hairConcerns.isNotEmpty;
      case 'skinType':
        return skinType != null && skinType!.trim().isNotEmpty;
      case 'goals':
        return goals.isNotEmpty;
      case 'sensitivities':
        return true; // Optional step
      default:
        return true;
    }
  }

  void toggleOption(QuizQuestion question, String optionId) {
    if (question.isMultiSelect) {
      List<String> targetList;
      switch (question.id) {
        case 'hairConcerns':
          targetList = hairConcerns;
          break;
        case 'goals':
          targetList = goals;
          break;
        case 'sensitivities':
          targetList = sensitivities;
          break;
        default:
          return;
      }

      if (question.id == 'sensitivities' && optionId == 'No Sensitivities') {
        if (targetList.contains('No Sensitivities')) {
          targetList.remove('No Sensitivities');
        } else {
          targetList.clear();
          targetList.add('No Sensitivities');
        }
        return;
      }

      if (question.id == 'sensitivities') {
        targetList.remove('No Sensitivities');
      }

      if (targetList.contains(optionId)) {
        targetList.remove(optionId);
      } else {
        targetList.add(optionId);
      }
    } else {
      switch (question.id) {
        case 'hairType':
          hairType = optionId;
          break;
        case 'skinType':
          skinType = optionId;
          break;
      }
    }
  }

  bool isOptionSelected(QuizQuestion question, String optionId) {
    if (question.isMultiSelect) {
      switch (question.id) {
        case 'hairConcerns':
          return hairConcerns.contains(optionId);
        case 'goals':
          return goals.contains(optionId);
        case 'sensitivities':
          return sensitivities.contains(optionId);
        default:
          return false;
      }
    } else {
      switch (question.id) {
        case 'hairType':
          return hairType == optionId;
        case 'skinType':
          return skinType == optionId;
        default:
          return false;
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'hairType': hairType ?? '',
      'hairConcerns': hairConcerns,
      'skinType': skinType ?? '',
      'goals': goals,
      'sensitivities': sensitivities,
    };
  }
}

class RecommendedProduct {
  final String productId;
  final String name;
  final String category;
  final double price;
  final String formattedPrice;
  final String imageUrl;
  final String matchReason;
  final List<String> features;
  final List<String> keyIngredients;

  const RecommendedProduct({
    required this.productId,
    required this.name,
    this.category = 'Hair',
    this.price = 0,
    required this.formattedPrice,
    required this.imageUrl,
    this.matchReason = '',
    this.features = const [],
    this.keyIngredients = const [],
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      productId: (json['productId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? 'Hair').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      formattedPrice:
          (json['formattedPrice'] ?? '₹${json['price'] ?? 0}').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      matchReason: (json['matchReason'] ?? json['baseReason'] ?? '').toString(),
      features: (json['features'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      keyIngredients: (json['keyIngredients'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'category': category,
        'price': price,
        'formattedPrice': formattedPrice,
        'imageUrl': imageUrl,
        'matchReason': matchReason,
        'features': features,
        'keyIngredients': keyIngredients,
      };
}

class RecommendedService {
  final String serviceId;
  final String name;
  final String category;
  final int duration;
  final double price;
  final String formattedPrice;
  final String description;
  final String matchReason;

  const RecommendedService({
    required this.serviceId,
    required this.name,
    this.category = 'Hair',
    this.duration = 60,
    this.price = 0,
    required this.formattedPrice,
    this.description = '',
    this.matchReason = '',
  });

  factory RecommendedService.fromJson(Map<String, dynamic> json) {
    return RecommendedService(
      serviceId: (json['serviceId'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      category: (json['category'] ?? 'Hair').toString(),
      duration: (json['duration'] as num?)?.toInt() ?? 60,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      formattedPrice:
          (json['formattedPrice'] ?? '₹${json['price'] ?? 0}').toString(),
      description: (json['description'] ?? '').toString(),
      matchReason: (json['matchReason'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'name': name,
        'category': category,
        'duration': duration,
        'price': price,
        'formattedPrice': formattedPrice,
        'description': description,
        'matchReason': matchReason,
      };
}

class RecommendedStylist {
  final String stylistId;
  final String name;
  final double rating;
  final int experience;
  final List<String> specialization;
  final String branchName;
  final String matchReason;

  const RecommendedStylist({
    required this.stylistId,
    required this.name,
    this.rating = 5.0,
    this.experience = 0,
    this.specialization = const [],
    this.branchName = 'VIORA Salon',
    this.matchReason = '',
  });

  factory RecommendedStylist.fromJson(Map<String, dynamic> json) {
    return RecommendedStylist(
      stylistId: (json['stylistId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      specialization: (json['specialization'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      branchName: (json['branchName'] ?? 'VIORA Salon').toString(),
      matchReason: (json['matchReason'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'stylistId': stylistId,
        'name': name,
        'rating': rating,
        'experience': experience,
        'specialization': specialization,
        'branchName': branchName,
        'matchReason': matchReason,
      };
}

class QuizResultModel {
  final String profileArchetype;
  final String summary;
  final List<String> profileChips;
  final List<RecommendedProduct> products;
  final List<RecommendedService> services;
  final List<RecommendedStylist> stylists;
  final int retakeCount;

  const QuizResultModel({
    required this.profileArchetype,
    required this.summary,
    required this.profileChips,
    required this.products,
    required this.services,
    this.stylists = const [],
    this.retakeCount = 0,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    final rec = (json['recommendations'] as Map<String, dynamic>?) ?? {};
    final prodsRaw =
        (rec['products'] ?? json['products']) as List<dynamic>? ?? [];
    final servsRaw =
        (rec['services'] ?? json['services']) as List<dynamic>? ?? [];
    final stylsRaw =
        (rec['stylists'] ?? json['stylists']) as List<dynamic>? ?? [];

    final prods = prodsRaw
        .map((p) => RecommendedProduct.fromJson(p as Map<String, dynamic>))
        .toList();
    final servs = servsRaw
        .map((s) => RecommendedService.fromJson(s as Map<String, dynamic>))
        .toList();
    final styls = stylsRaw
        .map((st) => RecommendedStylist.fromJson(st as Map<String, dynamic>))
        .toList();

    return QuizResultModel(
      profileArchetype:
          (json['profileArchetype'] ?? 'Luminous Glow & Hydration').toString(),
      summary: (json['summary'] ?? '').toString(),
      profileChips: (json['profileChips'] as List<dynamic>? ?? [])
          .map((c) => c.toString())
          .toList(),
      products: prods,
      services: servs,
      stylists: styls,
      retakeCount: (json['retakeCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'profileArchetype': profileArchetype,
        'summary': summary,
        'profileChips': profileChips,
        'recommendations': {
          'products': products.map((p) => p.toJson()).toList(),
          'services': services.map((s) => s.toJson()).toList(),
          'stylists': stylists.map((st) => st.toJson()).toList(),
        },
        'retakeCount': retakeCount,
      };
}
