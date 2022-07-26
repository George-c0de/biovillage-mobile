import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/account.dart';
import 'package:biovillage/api-client/account.dart';
import 'package:biovillage/models/address.dart';
import 'package:biovillage/pages/account/select-address.dart';
import 'package:biovillage/helpers/net-connection.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/widgets/appbar.dart';
import 'package:biovillage/widgets/button.dart';
import 'package:biovillage/widgets/form-elements.dart';
import 'package:biovillage/widgets/notifications.dart';
import 'package:biovillage/widgets/account/address-card.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _birthday = TextEditingController();
  TextEditingController _email = TextEditingController();
  DateTime _todayDate = DateTime.now();
  AnimationController _saveButtonConroller;
  AnimationController _changeBirthdayConroller;
  bool _settingsChanged = false;
  bool _settingsSaveLoading = false;
  bool _birthdayChangeLoading = false;
  String _nameError;
  String _birthdayError;
  String _emailError;
  final _inputHintStyle = TextStyle(fontSize: 13.w, fontWeight: FontWeight.w600, color: ColorsTheme.textTertiary);
  final _inputTextStyle = TextStyle(fontSize: 13.w, fontWeight: FontWeight.w600, color: ColorsTheme.textMain);

  void _selectBirthdayDate(bool birthdayIsUnset) async {
    if (_birthdayError != null) setState(() => _birthdayError = null);
    if (Platform.isIOS) {
      DateTime date = await showModalBottomSheet<DateTime>(
        context: context,
        builder: (context) {
          DateTime tempPickedDate;
          return Container(
            height: 250,
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CupertinoButton(
                        child: Text(FlutterI18n.translate(context, 'common.cancel')),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      CupertinoButton(
                        child: Text(FlutterI18n.translate(context, 'common.done')),
                        onPressed: () {
                          Navigator.of(context).pop(tempPickedDate);
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 1,
                ),
                Expanded(
                  child: Container(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      onDateTimeChanged: (DateTime dateTime) {
                        tempPickedDate = dateTime;
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
      if (date != null && date != _todayDate) {
        if (birthdayIsUnset) {
          setState(
              () => _birthday.text = DateFormat(FlutterI18n.translate(context, 'common.date_format')).format(date));
          _settingChanged();
        } else {
          _changeBirthday();
        }
      }
    } else {
      final DateTime date = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        lastDate: _todayDate,
        initialDate: _todayDate,
        helpText: FlutterI18n.translate(context, 'common.account.birthday_help_text'),
      );
      if (date != null && date != _todayDate) {
        if (birthdayIsUnset) {
          setState(
              () => _birthday.text = DateFormat(FlutterI18n.translate(context, 'common.date_format')).format(date));
          _settingChanged();
        } else {
          _changeBirthday();
        }
      }
    }
  }

  void _settingChanged() {
    if (!_settingsChanged) {
      _settingsChanged = true;
      _saveButtonConroller.forward();
    }
  }

  void _saveSettings() async {
    setState(() => _settingsSaveLoading = true);
    var store = StoreProvider.of<AppState>(context);
    bool failed = false;
    await store.dispatch(updateUserInfo(
      name: _name.text,
      birthday: _birthday.text,
      email: _email.text,
      onFailed: (errors) {
        if (errors == null) {
          // Если ошибки не пришли, то проверим подключение к нету:
          if (errors == null) checkConnect(context);
          failed = true;
        } else {
          setState(() {
            if (errors['name'] != null) _nameError = errors['name'];
            if (errors['birthday'] != null) _birthdayError = errors['birthday'];
            if (errors['email'] != null) _emailError = errors['email'];
          });
        }
      },
      onSuccess: () {
        showToast(FlutterI18n.translate(context, 'common.account.settings_saved'));
      },
    ));
    FocusScope.of(context).unfocus();
    if (!failed) {
      await _saveButtonConroller.reverse();
      _settingsChanged = false;
    }
    setState(() => _settingsSaveLoading = false);
  }

  void _changeBirthday() async {
    var store = StoreProvider.of<AppState>(context);
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() => _birthdayChangeLoading = true);
    var response = await ApiClientAccount.updateUserBirthday(
      store.state.account.userToken,
      birthday: _birthday.text,
    );
    if (response != null && response['success'] == true) {
      showToast(FlutterI18n.translate(context, 'common.account.birthday_change_request_sended'));
    } else {
      showToast(FlutterI18n.translate(context, 'common.account.birthday_change_request_failed'));
    }
    setState(() => _birthdayChangeLoading = false);
    _changeBirthdayConroller.reverse();
  }

  @override
  void initState() {
    super.initState();
    _saveButtonConroller = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _changeBirthdayConroller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var store = StoreProvider.of<AppState>(context);
      setState(() {
        _name.text = store.state.account.userInfo.name;
        _phone.text = store.state.account.userInfo.phone;
        _birthday.text = store.state.account.userInfo.birthday;
        _email.text = store.state.account.userInfo.email;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _phone.dispose();
    _birthday.dispose();
    _email.dispose();
    _saveButtonConroller.dispose();
    _changeBirthdayConroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: FlutterI18n.translate(context, 'common.account.profile')),
      body: StoreConnector<AppState, dynamic>(
        converter: (store) => store,
        builder: (context, store) {
          if (store.state.account.userInfo == null) return Container();
          List<Address> addresses = store.state.account.userInfo.addresses;
          String birthday = store.state.account.userInfo.birthday;
          bool birthdayIsUnset = birthday == null || birthday.isEmpty;
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8),
                    CustomTextFormField(
                      controller: _name,
                      hintText: FlutterI18n.translate(context, 'common.account.name'),
                      enabled: !_settingsSaveLoading,
                      textCapitalization: TextCapitalization.words,
                      hintStyle: _inputHintStyle,
                      textStyle: _inputTextStyle,
                      errorText: _nameError,
                      onChanged: (v) {
                        _settingChanged();
                        if (_nameError != null) setState(() => _nameError = null);
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _phone,
                      enabled: false,
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        if (birthdayIsUnset) {
                          _selectBirthdayDate(birthdayIsUnset);
                        } else {
                          if (_changeBirthdayConroller.status == AnimationStatus.completed)
                            _changeBirthdayConroller.reverse();
                          else
                            _changeBirthdayConroller.forward();
                        }
                      },
                      child: CustomTextFormField(
                        enabled: false,
                        controller: _birthday,
                        hintText: FlutterI18n.translate(context, 'common.account.birthday'),
                        suffixIcon: Icon(
                          birthdayIsUnset ? BvIcons.calendar : BvIcons.info_outlined,
                          color: ColorsTheme.textTertiary,
                        ),
                        hintStyle: _inputHintStyle,
                        textStyle: _inputTextStyle,
                        errorText: _birthdayError,
                      ),
                    ),
                    SizeTransition(
                      sizeFactor: CurvedAnimation(parent: _changeBirthdayConroller, curve: Curves.easeOut),
                      axisAlignment: -1,
                      child: Container(
                        clipBehavior: Clip.none,
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 22),
                        decoration: BoxDecoration(
                          color: ColorsTheme.bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ColorsTheme.primary),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    FlutterI18n.translate(context, 'common.account.birthday_change_hint'),
                                    style: TextStyle(fontSize: 13.w, height: 1.5),
                                  ),
                                ),
                                CircleButton(
                                  onTap: () => _changeBirthdayConroller.reverse(),
                                  size: 36,
                                  child: Icon(BvIcons.close, size: 24),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Button(
                              color: ButtonColor.primary,
                              outlined: true,
                              loading: _birthdayChangeLoading,
                              label: FlutterI18n.translate(context, 'common.send_request'),
                              onTap: () {
                                _selectBirthdayDate(birthdayIsUnset);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _email,
                      hintText: FlutterI18n.translate(context, 'common.account.email'),
                      enabled: !_settingsSaveLoading,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.emailAddress,
                      hintStyle: _inputHintStyle,
                      textStyle: _inputTextStyle,
                      errorText: _emailError,
                      onChanged: (v) {
                        _settingChanged();
                        if (_emailError != null) setState(() => _emailError = null);
                      },
                    ),
                    SizeTransition(
                      sizeFactor: _saveButtonConroller,
                      axisAlignment: .5,
                      child: ScaleTransition(
                        scale: _saveButtonConroller,
                        child: Container(
                          margin: EdgeInsets.only(top: 16),
                          child: Button(
                            onTap: () => _saveSettings(),
                            loading: _settingsSaveLoading,
                            color: ButtonColor.primary,
                            outlined: true,
                            label: FlutterI18n.translate(context, 'common.save'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    for (Address address in addresses) AddressCard(address: address),
                    Button(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/account/select-address',
                        arguments: SelectAddressPageArguments(addOnly: true),
                      ),
                      label: FlutterI18n.translate(context, 'common.account.add_address'),
                      color: ButtonColor.primary,
                      outlined: true,
                    ),
                    SizedBox(height: 16),
                    Button(
                      onTap: () {
                        StoreProvider.of<AppState>(context).dispatch(logout());
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      label: FlutterI18n.translate(context, 'common.account.logout'),
                      color: ButtonColor.primary,
                      flat: true,
                    ),
                    SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
