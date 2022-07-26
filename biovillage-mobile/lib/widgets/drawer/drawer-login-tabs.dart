import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/account.dart';
import 'package:biovillage/helpers/account.dart';
import 'package:biovillage/helpers/net-connection.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/pages/inapp-browser.dart';
import 'package:biovillage/widgets/drawer/drawer-tab.dart';
import 'package:biovillage/widgets/form-elements.dart';
import 'package:biovillage/widgets/notifications.dart';

/// Виджет таба с формой логина, шаг 1
class LoginStep1Tab extends StatefulWidget {
  LoginStep1Tab({Key key, @required this.onSuccess}) : super(key: key);
  final Function onSuccess;

  @override
  _LoginStep1TabState createState() => _LoginStep1TabState();
}

class _LoginStep1TabState extends State<LoginStep1Tab> {
  static final String _phoneMask = '+7 000 000-00-00';
  static final String _refCodeMask = '@@@@@@@@@@';
  bool _showRefCodeInput = false;
  bool _agreePolicy = true;
  MaskedTextController _phoneFieldController = MaskedTextController(mask: _phoneMask);
  MaskedTextController _refCodeFieldController = MaskedTextController(mask: _refCodeMask);
  String _phoneFieldErrorText;
  String _refCodeFieldErrorText;
  bool _smsSending = false;

  /// Отправка формы:
  void _submitFormStep1() async {
    bool vPhone = _validatePhoneField();
    bool vRefCode = _validateRefCodeField();
    if (!vPhone || !vRefCode) return;
    setState(() => _smsSending = true);
    var store = StoreProvider.of<AppState>(context);
    await store.dispatch(authRequest(
      phone: _phoneFieldController.text,
      refCode: _refCodeFieldController.text,
      onSuccess: () {
        showToast(FlutterI18n.translate(context, 'common.auth.sms_sended'));
        widget.onSuccess();
      },
      onFailed: (errors) {
        if (errors == null) {
          checkConnect(context);
          return;
        }
        if (errors['phone'] != null) setState(() => _phoneFieldErrorText = errors['phone']);
        if (errors['referral'] != null) setState(() => _refCodeFieldErrorText = errors['referral']);
      },
    ));
    setState(() => _smsSending = false);
  }

  /// Валидация телефона
  bool _validatePhoneField() {
    bool success = _phoneFieldController.text.length == _phoneMask.length;
    if (!success) setState(() => _phoneFieldErrorText = FlutterI18n.translate(context, 'common.auth.phone_error'));
    return success;
  }

  /// Валидация реф. кода
  bool _validateRefCodeField() {
    String code = _refCodeFieldController.text;
    if (code.isEmpty) return true;
    if (code.length < 6 || code.length > 10) {
      setState(() => _refCodeFieldErrorText = FlutterI18n.translate(context, 'common.auth.refcode_error'));
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();

    // Форматирование номера телефона при вводе:
    _phoneFieldController.beforeChange = (String prev, String next) {
      // Если юзер вставляет из буфера номер, начинающийся с 8:
      if (prev == '' && next.length > 1 && next.trim()[0] == '8') {
        Timer(Duration.zero, () => _phoneFieldController.updateText(next.trim().substring(1)));
        return false;
      }
      // Если юзер начиннет вводить телефон через 8:
      if (next == '8') _phoneFieldController.text = '+7 ';
      return true;
    };
    _phoneFieldController.afterChange = (String prev, String next) {
      // Сбрасываем ошибки ввода:
      if (prev != next) setState(() => _phoneFieldErrorText = null);
      // Если юзер закончил ввод телефона, то сразу спрячем кейборд:
      if (next.length > prev.length && next.length == _phoneMask.length) FocusScope.of(context).unfocus();
      // Если курсор прыгнул на позицию ноль, то вернем в конец (баг на iOS):
      if (_phoneFieldController.selection.baseOffset == 0 && _phoneFieldController.selection.extentOffset == 0) {
        int length = _phoneFieldController.text.length;
        _phoneFieldController.selection = TextSelection.fromPosition(TextPosition(offset: length));
      }
      return true;
    };

    // Форматирование реф.кода:
    _refCodeFieldController.afterChange = (String prev, String next) {
      // Сброс ошибок ввода реф. кода:
      if (prev != next) setState(() => _refCodeFieldErrorText = null);
      // Если юзер закончил ввод кода, то сразу спрячем кейборд:
      if (next.length > prev.length && next.length == _refCodeMask.length) FocusScope.of(context).unfocus();
      return true;
    };

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Если пользователь еще не входил, то покажем поле для реф.кода:
      bool userLogged = await getPrefsUserLogged();
      if (userLogged != true) setState(() => _showRefCodeInput = true);
    });
  }

  @override
  void dispose() {
    _phoneFieldController.dispose();
    _refCodeFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DrawerTab(
      title: FlutterI18n.translate(context, 'common.auth.enter'),
      actionBtnLabel: FlutterI18n.translate(context, 'common.auth.send_sms'),
      actionBtnOnTap: () => _submitFormStep1(),
      actionBtnLoading: _smsSending,
      actionBtnDisabled: !_agreePolicy,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              CustomTextFormField(
                controller: _phoneFieldController,
                keyboardType: TextInputType.number,
                hintText: FlutterI18n.translate(context, 'common.auth.phone_enter'),
                errorText: _phoneFieldErrorText,
                onFieldSubmitted: () => _validatePhoneField(),
              ),
              if (_showRefCodeInput) SizedBox(height: 16),
              if (_showRefCodeInput)
                CustomTextFormField(
                  controller: _refCodeFieldController,
                  textCapitalization: TextCapitalization.characters,
                  hintText: FlutterI18n.translate(context, 'common.auth.refcode_enter'),
                  errorText: _refCodeFieldErrorText,
                  onFieldSubmitted: () => _validateRefCodeField(),
                ),
              if (_showRefCodeInput) SizedBox(height: 16),
              if (_showRefCodeInput)
                Text(
                  FlutterI18n.translate(context, 'common.auth.refcode_hint'),
                  style: TextStyle(
                    fontSize: 11.w,
                    color: ColorsTheme.textTertiary,
                    height: 1.6,
                  ),
                ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.only(left: 3, right: 16),
          child: Row(
            children: [
              Checkbox(
                value: _agreePolicy,
                activeColor: ColorsTheme.primary,
                onChanged: (bool v) {
                  if (!_smsSending) setState(() => _agreePolicy = v);
                },
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: FlutterI18n.translate(context, 'common.account.policy_agree_text_before') + ' ',
                      ),
                      TextSpan(
                        text: FlutterI18n.translate(context, 'common.account.policy_agree_text_link'),
                        style: TextStyle(color: ColorsTheme.primary),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pushNamed(context, '/inapp-browser',
                              arguments: InappBrowserArguments(
                                initialUrl: FlutterI18n.translate(context, 'common.account.policy_agree_link_url'),
                                title: FlutterI18n.translate(context, 'common.policy_agreement'),
                              )),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 11.w, height: 1.3, color: ColorsTheme.textTertiary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Виджет таба с формой логина, шаг 2
class LoginStep2Tab extends StatefulWidget {
  LoginStep2Tab({Key key, @required this.onSuccess}) : super(key: key);
  final Function onSuccess;

  @override
  _LoginStep2TabState createState() => _LoginStep2TabState();
}

class _LoginStep2TabState extends State<LoginStep2Tab> {
  static final String _smsCodeMask = '00000';
  MaskedTextController _smsCodeFieldController = MaskedTextController(mask: _smsCodeMask);
  String _smsCodeFieldErrorText;
  bool _checkingSms = false;
  Timer _timer;
  int _timerSeconds = 0;

  /// Отправка формы:
  void _submitFormStep2() async {
    bool vSmsCode = _validateSmsCodeField();
    if (!vSmsCode) return;
    setState(() => _checkingSms = true);
    var store = StoreProvider.of<AppState>(context);
    await store.dispatch(authVerify(
      smsCode: _smsCodeFieldController.text,
      onSuccess: () {
        showToast(FlutterI18n.translate(context, 'common.auth.success_auth'));
        widget.onSuccess();
      },
      onFailed: (errors) {
        if (errors == null) {
          checkConnect(context);
          return;
        }
        if (errors['code'] != null) setState(() => _smsCodeFieldErrorText = errors['code']);
      },
    ));
    setState(() => _checkingSms = false);
  }

  /// Валидация смс-кода
  bool _validateSmsCodeField() {
    bool success = _smsCodeFieldController.text.length == _smsCodeMask.length;
    if (!success) setState(() => _smsCodeFieldErrorText = FlutterI18n.translate(context, 'common.auth.smscode_error'));
    return success;
  }

  /// Запуск таймера обратного отсчета для повторной отправки СМС
  void _startTimer() {
    _timerSeconds = 60;
    _timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_timerSeconds < 1) {
        timer.cancel();
      } else {
        setState(() {
          _timerSeconds -= 1;
        });
      }
    });
  }

  /// Повторная отправка СМС:
  void _sendSmsAgain() {
    _smsCodeFieldController.text = '';
    setState(() => _smsCodeFieldErrorText = null);
    _startTimer();
    var store = StoreProvider.of<AppState>(context);
    store.dispatch(authRequest(
      phone: store.state.account.authPhone,
      refCode: store.state.account.authRefCode,
    ));
  }

  @override
  void initState() {
    super.initState();
    // Форматирование смс-кода:
    _smsCodeFieldController.afterChange = (String prev, String next) {
      // Сброс ошибок ввода смс-кода:
      if (prev != next) {
        setState(() {
          _smsCodeFieldErrorText = null;
        });
      }
      // Если юзер закончил ввод кода, то сразу спрячем кейборд и отправим код на проверку:
      if (next.length > prev.length && next.length == _smsCodeMask.length) {
        FocusScope.of(context).unfocus();
        _submitFormStep2();
      }
      return true;
    };
    // Инициализация таймера повторной отправки СМС:
    _startTimer();
  }

  @override
  void dispose() {
    _smsCodeFieldController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DrawerTab(
      title: FlutterI18n.translate(context, 'common.auth.enter'),
      actionBtnLabel: FlutterI18n.translate(context, 'common.auth.enter'),
      actionBtnOnTap: () => _submitFormStep2(),
      actionBtnLoading: _checkingSms,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              CustomTextFormField(
                controller: _smsCodeFieldController,
                keyboardType: TextInputType.number,
                hintText: FlutterI18n.translate(context, 'common.auth.smscode_enter'),
                errorText: _smsCodeFieldErrorText,
                onFieldSubmitted: () => _validateSmsCodeField(),
              ),
              SizedBox(height: 10),
              MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                height: 24,
                onPressed: _timerSeconds < 1 ? () => _sendSmsAgain() : null,
                splashColor: ColorsTheme.secondary.withOpacity(.3),
                highlightColor: ColorsTheme.secondary.withOpacity(.15),
                disabledColor: ColorsTheme.textTertiary.withOpacity(.05),
                child: Text(
                  FlutterI18n.translate(context, 'common.auth.smscode_send_again'),
                  style: TextStyle(
                    fontSize: 11.w,
                    fontWeight: FontWeight.w500,
                    color: _timerSeconds < 1 ? ColorsTheme.secondary : ColorsTheme.textTertiary,
                  ),
                ),
              ),
              if (_timerSeconds > 0)
                Transform.translate(
                  offset: Offset(0, -6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        FlutterI18n.translate(context, 'common.auth.through').toLowerCase(),
                        style: TextStyle(fontSize: 10.w),
                      ),
                      SizedBox(width: 2),
                      Container(
                        width: 18,
                        child: Text(
                          '$_timerSeconds',
                          style: TextStyle(fontSize: 10.w),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 2),
                      Text(
                        FlutterI18n.translate(context, 'common.auth.sec').toLowerCase(),
                        style: TextStyle(fontSize: 10.w),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
