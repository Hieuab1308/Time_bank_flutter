import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/domain/profile.dart';
import '../../profile/providers/providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final Profile profile;
  const EditProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _facebookCtrl;
  late final TextEditingController _instaCtrl;
  late final TextEditingController _tiktokCtrl;
  late final TextEditingController _regionCtrl;
  late final TextEditingController _workCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _studyCtrl;
  DateTime? _birthDate;
  late final TextEditingController _birthCtrl;
  bool _showRegion = true;
  bool _showWork = true;
  bool _showStreet = true;
  bool _showBirthDate = true;
  bool _showStudy = true;
  bool _editingStreet = false;
  bool _editingBirthDate = false;
  final Map<String, String> _backupText = {};
  final Map<String, DateTime?> _backupDate = {};

  late final FocusNode _nameFocus;
  late final FocusNode _descFocus;
  late final FocusNode _regionFocus;
  late final FocusNode _workFocus;
  late final FocusNode _streetFocus;
  late final FocusNode _studyFocus;
  late final FocusNode _facebookFocus;
  late final FocusNode _instaFocus;
  late final FocusNode _tiktokFocus;

  bool _isSaving = false;
  String _regionId = '';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _descCtrl = TextEditingController(text: widget.profile.description ?? '');
    _facebookCtrl = TextEditingController(
        text: widget.profile.socialNetwork?['facebook'] ?? '');
    _instaCtrl = TextEditingController(
        text: widget.profile.socialNetwork?['instagram'] ?? '');
    _tiktokCtrl = TextEditingController(
        text: widget.profile.socialNetwork?['tiktok'] ?? '');

    _regionId = widget.profile.regionId ?? '';
    _regionCtrl = TextEditingController(
        text: widget.profile.fullRegionAddress ??
            widget.profile.regionName ??
            _regionId);

    _workCtrl = TextEditingController(text: widget.profile.workAddress ?? '');
    _streetCtrl = TextEditingController(text: widget.profile.street ?? '');
    _studyCtrl = TextEditingController(text: widget.profile.studyAddress ?? '');
    _birthDate = widget.profile.birthDate;

    if (_birthDate != null) {
      final localDate = _birthDate!.toLocal();
      _birthCtrl = TextEditingController(
          text:
              '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}');
    } else {
      _birthCtrl = TextEditingController(text: '');
    }

    _nameFocus = FocusNode();
    _descFocus = FocusNode();
    _regionFocus = FocusNode();
    _workFocus = FocusNode();
    _streetFocus = FocusNode();
    _studyFocus = FocusNode();
    _facebookFocus = FocusNode();
    _instaFocus = FocusNode();
    _tiktokFocus = FocusNode();
    _nameFocus.addListener(() => setState(() {}));
    _descFocus.addListener(() => setState(() {}));
    _regionFocus.addListener(() => setState(() {}));
    _workFocus.addListener(() => setState(() {}));
    _streetFocus.addListener(() => setState(() {}));
    _studyFocus.addListener(() => setState(() {}));
    _facebookFocus.addListener(() => setState(() {}));
    _instaFocus.addListener(() => setState(() {}));
    _tiktokFocus.addListener(() => setState(() {}));
    _descFocus.addListener(() => setState(() {}));
    _showRegion = true;
    _showWork = true;
    _showStreet = true;
    _showBirthDate = true;
    _showStudy = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _facebookCtrl.dispose();
    _instaCtrl.dispose();
    _tiktokCtrl.dispose();
    _regionCtrl.dispose();
    _workCtrl.dispose();
    _streetCtrl.dispose();
    _studyCtrl.dispose();
    _nameFocus.dispose();
    _descFocus.dispose();
    _regionFocus.dispose();
    _workFocus.dispose();
    _streetFocus.dispose();
    _studyFocus.dispose();
    _facebookFocus.dispose();
    _instaFocus.dispose();
    _tiktokFocus.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final Map<String, dynamic> dto = {
      'full_name': _nameCtrl.text.trim(),
      'email': widget.profile.email,
      'phone': widget.profile.phone,
      'description': _descCtrl.text.trim(),
      'region_id': _regionId,
      'work_address': _workCtrl.text.trim(),
      'street': _streetCtrl.text.trim(),
      'study_address': _studyCtrl.text.trim(),
      'birth_date': _birthDate?.toUtc().toIso8601String(),
      'social_network': {
        'facebook': _facebookCtrl.text.trim(),
        'instagram': _instaCtrl.text.trim(),
        'tiktok': _tiktokCtrl.text.trim(),
      },
    };

    final visibility = {
      'region': _showRegion,
      'work': _showWork,
      'street': _showStreet,
      'birthDate': _showBirthDate,
      'study': _showStudy,
    };

    ref.read(updateProfileProvider(dto).future).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Đã lưu thay đổi')));
        Navigator.of(context).pop({'visibility': visibility});
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi khi lưu: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }).whenComplete(() {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate?.toLocal() ?? DateTime(now.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D4C7B),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF0D4C7B),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null)
      setState(() {
        _birthDate = picked;
        _birthCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: Color(0xFF003E77),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFieldWithToggle(
                fieldKey: 'name',
                label: 'Họ và tên',
                controller: _nameCtrl,
                focusNode: _nameFocus,
                isVisible: true,
                isEditing: false,
                onToggle: (_) {},
                onEdit: () {},
                readOnly: true
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white,
                elevation: 0,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                              child: Text('Mô tả ngắn',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500))),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () {
                              _backupText['description'] = _descCtrl.text;
                              Future.delayed(
                                  const Duration(milliseconds: 80),
                                  () => FocusScope.of(context)
                                      .requestFocus(_descFocus));
                            },
                            splashRadius: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_descFocus.hasFocus) ...[
                        TextFormField(
                          controller: _descCtrl,
                          focusNode: _descFocus,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _descCtrl.text = _backupText['description'] ??
                                      _descCtrl.text;
                                  FocusScope.of(context).unfocus();
                                  _backupText.remove('description');
                                });
                              },
                              child: const Text('Hủy'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  FocusScope.of(context).unfocus();
                                  _backupText.remove('description');
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D4C7B)),
                              child: const Text('Lưu',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 6),
                          child: Text(
                            _descCtrl.text.trim().isEmpty
                                ? 'Chưa có'
                                : _descCtrl.text.trim(),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildFieldWithToggle(
                fieldKey: 'region',
                label: 'Đến từ',
                controller: _regionCtrl,
                focusNode: _regionFocus,
                isVisible: _showRegion,
                isEditing: false,
                readOnly: true,
                onToggle: (v) => setState(() => _showRegion = v),
                onEdit: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Không thể sửa trường này')));
                },
              ),
              const SizedBox(height: 8),
              _buildFieldWithToggle(
                fieldKey: 'work',
                label: 'Làm việc tại',
                controller: _workCtrl,
                focusNode: _workFocus,
                isVisible: _showWork,
                isEditing: false,
                onToggle: (v) => setState(() => _showWork = v),
                onEdit: () {
                  _backupText['work'] = _workCtrl.text;
                  setState(() => _showWork = true);
                  Future.delayed(const Duration(milliseconds: 80),
                      () => FocusScope.of(context).requestFocus(_workFocus));
                },
              ),
              const SizedBox(height: 8),
              _buildFieldWithToggle(
                fieldKey: 'street',
                label: 'Địa chỉ',
                controller: _streetCtrl,
                focusNode: _streetFocus,
                isVisible: _showStreet,
                isEditing: _editingStreet,
                onToggle: (v) => setState(() => _showStreet = v),
                onEdit: () {
                  _backupText['street'] = _streetCtrl.text;
                  setState(() {
                    _showStreet = true;
                    _editingStreet = true;
                  });
                  Future.delayed(const Duration(milliseconds: 80),
                      () => FocusScope.of(context).requestFocus(_streetFocus));
                },
              ),
              const SizedBox(height: 8),
              _buildDateFieldWithToggle(
                fieldKey: 'birthDate',
                label: 'Ngày sinh',
                date: _birthDate,
                isVisible: _showBirthDate,
                isEditing: _editingBirthDate,
                onToggle: (v) => setState(() => _showBirthDate = v),
                onTap: () {
                  if (_editingBirthDate) _pickBirthDate();
                },
                onEdit: () {
                  _backupDate['birthDate'] = _birthDate;
                  setState(() {
                    _showBirthDate = true;
                    _editingBirthDate = true;
                  });
                  Future.delayed(
                      const Duration(milliseconds: 60), () => _pickBirthDate());
                },
              ),
              const SizedBox(height: 8),
              _buildFieldWithToggle(
                fieldKey: 'study',
                label: 'Học tại',
                controller: _studyCtrl,
                focusNode: _studyFocus,
                isVisible: _showStudy,
                isEditing: false,
                onToggle: (v) => setState(() => _showStudy = v),
                onEdit: () {
                  _backupText['study'] = _studyCtrl.text;
                  setState(() => _showStudy = true);
                  Future.delayed(const Duration(milliseconds: 80),
                      () => FocusScope.of(context).requestFocus(_studyFocus));
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ))
                      : const Text('Lưu thay đổi'),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D4C7B),
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldWithToggle({
    required String fieldKey,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isVisible,
    required bool isEditing,
    required ValueChanged<bool> onToggle,
    required VoidCallback onEdit,
    String? prefix,
    bool readOnly = false,
  })
  {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(label,
                        style: const TextStyle(fontWeight: FontWeight.w500))),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEditing || focusNode.hasFocus) ...[
                      IconButton(
                        icon: const Icon(Icons.check, size: 18),
                        onPressed: () {
                          setState(() {
                            if (fieldKey == 'street') _editingStreet = false;
                            FocusScope.of(context).unfocus();
                            _backupText.remove(fieldKey);
                          });
                        },
                        splashRadius: 18,
                      ),
                    ] else ...[
                      IconButton(
                        icon: Icon(Icons.edit,
                            size: 18,
                            color: readOnly ? Colors.grey : Colors.black),
                        onPressed: onEdit,
                        splashRadius: 18,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (isVisible) ...[
              const SizedBox(height: 8),
              if (isEditing || focusNode.hasFocus) ...[
                TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  readOnly: readOnly,
                  decoration: InputDecoration(
                      labelText: label,
                      prefixText: prefix,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          controller.text =
                              _backupText[fieldKey] ?? controller.text;
                          if (fieldKey == 'street') _editingStreet = false;
                          FocusScope.of(context).unfocus();
                          _backupText.remove(fieldKey);
                        });
                      },
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (fieldKey == 'street') _editingStreet = false;
                          FocusScope.of(context).unfocus();
                          _backupText.remove(fieldKey);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D4C7B),
                          foregroundColor: Colors.white),
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  child: Text(
                    controller.text.trim().isEmpty
                        ? 'Chưa có'
                        : controller.text.trim(),
                    style: TextStyle(
                        fontSize: 14,
                        color: readOnly ? Colors.black : Colors.black87),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateFieldWithToggle({
    required String fieldKey,
    required String label,
    required DateTime? date,
    required bool isVisible,
    required bool isEditing,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTap,
    required VoidCallback onEdit,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(label,
                        style: const TextStyle(fontWeight: FontWeight.w500))),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEditing) ...[
                      IconButton(
                        icon: const Icon(Icons.check, size: 18),
                        onPressed: () {
                          setState(() {
                            _editingBirthDate = false;
                            FocusScope.of(context).unfocus();
                            _backupDate.remove(fieldKey);
                          });
                        },
                        splashRadius: 18,
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: onEdit,
                        splashRadius: 18,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (isVisible) ...[
              const SizedBox(height: 8),
              if (isEditing) ...[
                TextFormField(
                  controller: _birthCtrl,
                  readOnly: true,
                  onTap: onTap,
                  decoration: InputDecoration(
                      labelText: label,
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                      filled: true,
                      fillColor: Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _birthDate = _backupDate[fieldKey];
                          final localDate = _birthDate?.toLocal();
                          _birthCtrl.text = localDate == null
                              ? ''
                              : '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
                          _editingBirthDate = false;
                          _backupDate.remove(fieldKey);
                        });
                      },
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _editingBirthDate = false;
                          _backupDate.remove(fieldKey);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D4C7B),
                          foregroundColor: Colors.white),
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
              ] else
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  child: Text(
                    date == null
                        ? 'Chưa có'
                        : '${date.toLocal().day.toString().padLeft(2, '0')}/${date.toLocal().month.toString().padLeft(2, '0')}/${date.toLocal().year}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
