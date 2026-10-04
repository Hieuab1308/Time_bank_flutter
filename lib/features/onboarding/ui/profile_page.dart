import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/onboarding/ui/enter_password.dart';
import 'package:time_bank_flutter/features/onboarding/providers/onboarding_providers.dart';
import 'package:time_bank_flutter/features/onboarding/providers/region_providers.dart';
import 'package:time_bank_flutter/features/auth/ui/login_page.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _checkingUnique = false;
  DateTime? selectedDate;

  String? _emailErrorText;
  String? _cccdErrorText;

  String? gender; // "Nam" | "Nữ" | "Khác"
  String? major;  // skill_id

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetForm();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _cccdController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _resetRegionSelections() {
    ref.read(selectedProvinceIdProvider.notifier).state = null;
    ref.read(selectedDistrictIdProvider.notifier).state = null;
    ref.read(selectedWardIdProvider.notifier).state = null;

    ref.invalidate(provincesProvider);
    ref.invalidate(districtsProvider);
    ref.invalidate(wardsProvider);
  }

  void _resetForm() {
    _nameController.clear();
    _emailController.clear();
    _cccdController.clear();
    _dateController.clear();
    selectedDate = null;
    gender = null;
    major  = null;

    _emailErrorText = null;
    _cccdErrorText = null;

    _resetRegionSelections();

    ref.read(onboardingControllerProvider.notifier).setPersonalDraft(
      fullName: null,
      email: null,
      cccd: null,
      birthdate: null,
      gender: null,
      regionId: null,
      specialization: null,
    );

    setState(() {});
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D1B4C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF0D1B4C)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Widget _buildLabel(String text, {bool isRequired = true}) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        if (isRequired)
          const Text(" *", style: TextStyle(color: Colors.red, fontSize: 14)),
      ],
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    String? genderEnum;
    if (gender == "Nam") {
      genderEnum = "male";
    } else if (gender == "Nữ") {
      genderEnum = "female";
    } else if (gender == "Khác") {
      genderEnum = "other";
    } else {
      genderEnum = "unknown";
    }

    final wardSel = ref.read(selectedWardIdProvider);
    if (major == null || major!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn chuyên môn')),
      );
      return;
    }
    if (wardSel == null || wardSel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đủ Tỉnh/Thành phố, Quận/Huyện, Xã/Phường'),
        ),
      );
      return;
    }

    setState(() {
      _emailErrorText = null;
      _cccdErrorText  = null;
      _checkingUnique = true;
    });

    final email = _emailController.text.trim();
    final cccd  = _cccdController.text.trim();
    final repo  = ref.read(onboardingRepoProvider);

    try {
      final unique = await repo.checkUnique(
        email: email.isEmpty ? null : email,
        citizenId: cccd.isEmpty ? null : cccd,
      );

      bool hasInlineError = false;
      if (unique['email_taken'] == true) {
        _emailErrorText = 'Email đã được sử dụng';
        hasInlineError = true;
      }
      if (unique['citizen_id_taken'] == true) {
        _cccdErrorText = 'CCCD đã được sử dụng';
        hasInlineError = true;
      }

      setState(() {
        _checkingUnique = false;
      });

      if (hasInlineError) {
        setState(() {});
        return;
      }
    } catch (e) {
      setState(() => _checkingUnique = false);
    }

    if (_emailErrorText != null || _cccdErrorText != null) return;

    ref.read(onboardingControllerProvider.notifier).setPersonalDraft(
      fullName: _nameController.text.trim(),
      email: email.isEmpty ? null : email,
      cccd: cccd.isEmpty ? null : cccd,
      birthdate: selectedDate,
      gender: genderEnum,
      regionId: wardSel,
      specialization: major,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PasswordSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final skillsAsync = ref.watch(skillsProvider);
    final provinceSel = ref.watch(selectedProvinceIdProvider);
    final districtSel = ref.watch(selectedDistrictIdProvider);
    final wardSel = ref.watch(selectedWardIdProvider);
    final provinces = ref.watch(provincesProvider);
    final districts = ref.watch(districtsProvider);
    final wards = ref.watch(wardsProvider);
    final fullAddressAsync = ref.watch(fullAddressTextProvider);

    ref.listen(onboardingControllerProvider, (prev, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  "Thông tin cá nhân",
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Căn cước công dân"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _cccdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Nhập số CCCD",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorText: _cccdErrorText,
                          ),
                          onChanged: (_) {
                            if (_cccdErrorText != null) {
                              setState(() => _cccdErrorText = null);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập CCCD";
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return "CCCD chỉ được chứa số";
                            }
                            if (value.length != 12) {
                              return "CCCD phải đủ 12 số";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildLabel("Email", isRequired: false),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Nhập email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorText: _emailErrorText,
                          ),
                          onChanged: (_) {
                            if (_emailErrorText != null) {
                              setState(() => _emailErrorText = null);
                            }
                          },
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return "Email không hợp lệ";
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildLabel("Họ và tên"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            hintText: "Nhập họ và tên",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập họ và tên";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildLabel("Ngày sinh"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Chọn ngày sinh",
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: _pickDate,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Vui lòng chọn ngày sinh"
                              : null,
                        ),
                        const SizedBox(height: 20),

                        _buildLabel("Giới tính"),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: gender,
                          items: const [
                            DropdownMenuItem(value: "Nam", child: Text("Nam")),
                            DropdownMenuItem(value: "Nữ", child: Text("Nữ")),
                            DropdownMenuItem(value: "Khác", child: Text("Khác")),
                          ],
                          onChanged: (value) => setState(() => gender = value),
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: "Chọn giới tính",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                          (value == null || value.isEmpty)
                              ? "Vui lòng chọn giới tính"
                              : null,
                        ),
                        const SizedBox(height: 20),

                        _buildLabel("Chuyên môn"),
                        const SizedBox(height: 6),
                        skillsAsync.when(
                          data: (skills) {
                            return DropdownButtonFormField<String>(
                              value: major, // skill_id
                              isExpanded: true,
                              menuMaxHeight: 320,
                              items: skills.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s.id,
                                  child: Text(
                                    s.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => major = value),
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                hintText: "Chọn chuyên môn",
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? "Vui lòng chọn chuyên môn"
                                  : null,
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Lỗi tải kỹ năng: $e'),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel("Địa chỉ"),
                        const SizedBox(height: 6),
                        provinces.when(
                          data: (items) => DropdownButtonFormField<String>(
                            value: provinceSel,
                            isExpanded: true,
                            items: items
                                .map((r) => DropdownMenuItem(
                              value: r.id,
                              child: Text(r.name),
                            ))
                                .toList(),
                            dropdownColor: Colors.white,
                            onChanged: (val) {
                              ref.read(selectedProvinceIdProvider.notifier).state = val;
                              ref.read(selectedDistrictIdProvider.notifier).state = null;
                              ref.read(selectedWardIdProvider.notifier).state = null;
                            },
                            decoration: InputDecoration(
                              hintText: "Chọn Tỉnh/Thành phố",
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? "Vui lòng chọn Tỉnh/Thành phố"
                                : null,
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Lỗi tải Tỉnh/Thành: $e'),
                        ),
                        const SizedBox(height: 12),
                        districts.when(
                          data: (items) => DropdownButtonFormField<String>(
                            value: districtSel,
                            isExpanded: true,
                            items: items
                                .map((r) => DropdownMenuItem(
                              value: r.id,
                              child: Text(r.name),
                            ))
                                .toList(),
                            dropdownColor: Colors.white,
                            onChanged: provinceSel == null
                                ? null
                                : (val) {
                              ref.read(selectedDistrictIdProvider.notifier).state = val;
                              ref.read(selectedWardIdProvider.notifier).state = null;
                            },
                            decoration: InputDecoration(
                              hintText: "Chọn Quận/Huyện",
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (v) {
                              if (provinceSel != null && (v == null || v.isEmpty)) {
                                return "Vui lòng chọn Quận/Huyện";
                              }
                              return null;
                            },
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Lỗi tải Quận/Huyện: $e'),
                        ),
                        const SizedBox(height: 12),
                        wards.when(
                          data: (items) => DropdownButtonFormField<String>(
                            value: wardSel,
                            isExpanded: true,
                            items: items
                                .map((r) => DropdownMenuItem(
                              value: r.id,
                              child: Text(r.name),
                            ))
                                .toList(),
                            dropdownColor: Colors.white,
                            onChanged: districtSel == null
                                ? null
                                : (val) {
                              ref.read(selectedWardIdProvider.notifier).state = val;
                            },
                            decoration: InputDecoration(
                              hintText: "Chọn Xã/Phường",
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (v) {
                              if (districtSel != null && (v == null || v.isEmpty)) {
                                return "Vui lòng chọn Xã/Phường";
                              }
                              return null;
                            },
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Lỗi tải Xã/Phường: $e'),
                        ),

                        fullAddressAsync.when(
                          data: (text) => text == null
                              ? const SizedBox.shrink()
                              : Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "Địa chỉ: $text",
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 34),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (state.loading || _checkingUnique) ? null : _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D1B4C),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: (state.loading || _checkingUnique)
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text("Tiếp theo"),
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: state.loading
                                ? null
                                : () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0D1B4C),
                              side: const BorderSide(color: Color(0xFF0D1B4C)),
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Hủy"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
