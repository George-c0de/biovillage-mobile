import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/redux/state/app-state.dart';
import 'package:biovillage/redux/actions/catalog.dart';
import 'package:biovillage/models/filter-tag.dart';
import 'package:biovillage/theme/colors.dart';

class FilterTags extends StatefulWidget {
  FilterTags({Key key, this.onChange}) : super(key: key);
  final Function onChange;

  @override
  _FilterTagsState createState() => _FilterTagsState();
}

class _FilterTagsState extends State<FilterTags> {
  void _toggleTag(int tagId, bool val) {
    var store = StoreProvider.of<AppState>(context);
    store.dispatch(toggleFilterTag(tagId, val));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (store) => store,
      builder: (context, store) => Theme(
        data: ThemeData(
          splashColor: ColorsTheme.chipsText,
          highlightColor: Colors.transparent,
          accentColor: Colors.white.withOpacity(0),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
          child: Stack(
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (FilterTag tag in store.state.catalog.tags)
                    FilterChip(
                      label: Text(tag.name),
                      showCheckmark: false,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      labelStyle: TextStyle(
                        color: ColorsTheme.chipsText,
                        fontWeight: FontWeight.w500,
                        fontSize: 11.w,
                        fontFamily: 'Montserrat',
                      ),
                      backgroundColor: ColorsTheme.bg,
                      selectedColor: ColorsTheme.textFieldBg,
                      elevation: 10,
                      shadowColor: Color.fromRGBO(123, 49, 110, 0.1),
                      selectedShadowColor: Colors.transparent.withOpacity(0),
                      selected: tag.active,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: tag.active ? ColorsTheme.chipsBorder : Colors.transparent,
                        ),
                      ),
                      onSelected: (bool val) => _toggleTag(tag.id, val),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
