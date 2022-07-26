import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/theme/bv-icons.dart';
import 'package:biovillage/theme/colors.dart';
import 'package:biovillage/helpers/colors.dart';

typedef SearchInputChangedCallback = Function(String value);

class SearchInput extends StatefulWidget {
  SearchInput({
    Key key,
    this.isLink = false,
    this.focusNode,
    this.onChanged,
  }) : super(key: key);

  final bool isLink;
  final FocusNode focusNode;
  final SearchInputChangedCallback onChanged;

  @override
  _SearchInputState createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  TextEditingController _textController = TextEditingController();
  bool _showResetButton = false;

  /// Стиль текста в инпуте:
  final TextStyle textFieldTextStyle = TextStyle(
    color: ColorsTheme.textSecondary,
    fontSize: 13.w,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  void onChanged(String value) async {
    // Показываем и прячем кнопку сброса:
    if (value.length > 0 && !_showResetButton) {
      setState(() {
        _showResetButton = true;
      });
    } else if (value.length == 0 && _showResetButton) {
      setState(() {
        _showResetButton = false;
      });
    }
    // Коллбэк:
    if (widget.onChanged != null) widget.onChanged(value);
  }

  @override
  void initState() {
    _textController.text = '';
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => widget.isLink ? Navigator.pushNamed(context, '/search') : null,
        child: TextField(
          enabled: widget.isLink ? false : true,
          controller: _textController,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.isLink ? darken(ColorsTheme.textFieldBg, .2).withOpacity(.1) : ColorsTheme.textFieldBg,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(32),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            prefixIcon: Icon(BvIcons.search, color: ColorsTheme.accent, size: 18),
            suffixIcon: Material(
              color: Colors.transparent,
              child: _showResetButton
                  ? IconButton(
                      splashRadius: 16,
                      color: ColorsTheme.textTertiary,
                      icon: Icon(BvIcons.close),
                      onPressed: () {
                        _textController.text = '';
                        onChanged('');
                      },
                    )
                  : null,
            ),
            hintText: FlutterI18n.translate(context, 'common.search.find'),
            hintStyle: textFieldTextStyle,
          ),
          style: textFieldTextStyle,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (value) => onChanged(value),
        ),
      ),
    );
  }
}
