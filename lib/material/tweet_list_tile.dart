import 'dart:collection';
import 'dart:core';
import 'dart:ffi';

import 'package:dart_twitter_api/api/tweets/data/tweet.dart';
import 'package:dart_twitter_api/api/users/data/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:surtr_tw/components/utils/utils.dart';
import 'package:surtr_tw/pages/home/simple_list_tile.dart';

final Logger _log = Logger('HomeTimelineTile');

enum Hyperlinks { mention, tag, url }

class TweetListTile extends StatelessWidget {
  TweetListTile(this.tweet, this.isFirst, this.isDetail, {this.replyScreenName})
      : isRetweeted = tweet.retweetedStatus != null,
        isQuoted = tweet.isQuoteStatus,
        sourceTweet =
            tweet.retweetedStatus == null ? tweet : tweet.retweetedStatus;

  final Tweet tweet;
  final Tweet sourceTweet;
  final bool isFirst;
  final bool isRetweeted;
  final bool isQuoted;
  final bool isDetail;
  final String replyScreenName;

  @override
  Widget build(BuildContext context) {
    return isDetail
        ? Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              children: [
                Padding(
                  padding: isRetweeted ? EdgeInsets.fromLTRB(64, 4, 0, 4) : EdgeInsets.zero,
                  child: Row(
                    children: [
                      _typeIcon,
                      _typeWord,
                    ],
                  ),
                ),
                Row(
                  children: [_headImage, _title],
                  mainAxisSize: MainAxisSize.max,
                ),
                _contentText,
                // Padding(
                //   padding: EdgeInsets.symmetric(vertical: 4),
                //   child: Text(
                //     'Translate Tweet',
                //     style: TextStyleManager.blue_3,
                //   ),
                // ),
                _media,
                _time,
                Divider(indent: 4, endIndent: 4, thickness: .6,),
                _shareData,
                Divider(indent: 4, endIndent: 4, thickness: .6,),
                _shareIcons,
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
            ),
          )
        : Container(
            decoration: BoxDecoration(
                border: Border(top: BorderSide(width: isFirst? 0 : .6, color: CustomColor.DivGrey))),
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, isFirst ? 8 : 4, 4, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(children: [_typeIcon, _headImage]),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _typeWord,
                          _title,
                          if (replyScreenName != null) _target,
                          _contentText,
                          _media,
                          _options
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Widget get _target {
    return Text.rich(TextSpan(
      children: [
        TextSpan(text: 'Replying to ', style: TextStyleManager.grey_35),
        TextSpan(text: '@$replyScreenName', style: TextStyleManager.blue_23)
      ],
    ), overflow: TextOverflow.ellipsis, maxLines: 1,);
  }

  Widget get _shareIcons {
    return Row(
      children: [
        Icon(Icons.mode_comment_outlined, size: 24, color: Colors.grey),
        Icon(Icons.repeat_outlined, size: 24, color: Colors.grey),
        Icon(Icons.favorite_outline, size: 24, color: Colors.grey),
        Icon(Icons.share_outlined, size: 24, color: Colors.grey)
      ],
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    );
  }

  Widget get _shareData {
    return Text.rich(TextSpan(
      children: [
        TextSpan(text: sourceTweet.retweetCount == null ? '0' : sourceTweet.retweetCount.toString(), style: TextStyleManager.black_35_b),
        TextSpan(text: ' Retweets   ', style: TextStyleManager.grey_35),
        TextSpan(text: sourceTweet.quoteCount == null ? '0' : sourceTweet.quoteCount.toString(), style: TextStyleManager.black_35_b),
        TextSpan(text: ' Quote Tweets   ', style: TextStyleManager.grey_35),
        TextSpan(text: sourceTweet.favoriteCount == null ? '0' : sourceTweet.favoriteCount.toString(), style: TextStyleManager.black_35_b),
        TextSpan(text: ' Likes   ', style: TextStyleManager.grey_35),
      ]
    ));
  }

  Widget get _time {
    DateTime createAt = sourceTweet.createdAt;
    int startIndex = sourceTweet.source.indexOf('>') + 1;
    int endIndex = sourceTweet.source.indexOf('<\/a>');
    String from = sourceTweet.source.substring(startIndex, endIndex);
    return Text.rich(TextSpan(children: [
      TextSpan(
          text:
              '${createAt.hour}:${createAt.minute} · ${createAt.day} ${TimeUtil.month[createAt.month]} ${createAt.year.toString().substring(2, 4)} · ',
          style: TextStyleManager.grey_35),
      TextSpan(text: from, style: TextStyleManager.blue_23)
    ]));
  }

  Widget get _typeIcon {
    if (isRetweeted) {
      return SizedBox(
        height: 20,
      );
    } else {
      return Container();
    }
  }

  Widget get _typeWord {
    if (isRetweeted) {
      return Text(
        '${tweet.user.name} Retweeted',
        style: TextStyleManager.grey_15,
      );
    } else {
      return Container();
    }
  }

  Widget get _headImage {
    String obtainedUrl = sourceTweet.user.profileImageUrlHttps;
    // 改为原图Url
    String originalVariant = obtainedUrl.replaceAll('_normal.', '.');

    return Padding(
      padding: EdgeInsets.only(top: 6),
      child: _buildHeadImage(originalVariant),
    );
  }

  Widget get _userName {
    return isDetail
        ? Text(
            '${sourceTweet.user.name} ',
            style: TextStyleManager.black_35_b,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          )
        : Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: '${sourceTweet.user.name} ',
                    style: TextStyleManager.black_35_b),
                TextSpan(
                    text:
                        '@${sourceTweet.user.screenName} · ${TimeUtil.getTimeIntervalStr(sourceTweet.createdAt)}',
                    style: TextStyleManager.grey_35)
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );
  }

  Widget get _screenName {
    return Text(
      '@${sourceTweet.user.screenName}',
      style: TextStyleManager.grey_35,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  // 推文正文
  Widget get _contentText {
    // tag 和 url 的开始下标
    var hyperlinks = Map<int, Hyperlinks>();
    // tag 和 url 的截止下标
    var tagQueue = Queue<int>();
    var urlQueue = Queue<int>();
    var mentionQueue = Queue<int>();
    String fullText = sourceTweet.fullText;
    // 字符差值
    int diff = fullText.length - fullText.runes.length;
    // 正文截断
    fullText = fullText.substring(sourceTweet.displayTextRange[0],
        sourceTweet.displayTextRange[1] + diff);

    // 替换 url 后的实际结束下标
    int lastMark = 0;
    for (int i = 0; i < sourceTweet.entities.urls.length; ++i) {
      String url = sourceTweet.entities.urls[i].url;
      String displayUrl = sourceTweet.entities.urls[i].displayUrl;
      // url 替换
      int curStartIndex = fullText.indexOf(url, lastMark);
      if (curStartIndex != -1) {
        fullText = fullText.replaceRange(
            curStartIndex, curStartIndex + url.length, displayUrl);
        lastMark = curStartIndex + displayUrl.length;
        // url indexes
        hyperlinks.addAll({curStartIndex: Hyperlinks.url});
        urlQueue.add(curStartIndex + displayUrl.length);
      }
    }

    lastMark = 0;
    for (int i = 0; i < sourceTweet.entities.userMentions.length; ++i) {
      String mention = sourceTweet.entities.userMentions[i].screenName;
      int curStartIndex = fullText.indexOf('@$mention', lastMark);
      if (curStartIndex != -1) {
        lastMark = curStartIndex + mention.length + 1;
        hyperlinks.addAll({curStartIndex: Hyperlinks.mention});
        mentionQueue.add(curStartIndex + mention.length + 1);
      }
    }

    // 上次标记 Tag 的结束下标
    lastMark = 0;
    // tag indexes
    for (int i = 0; i < sourceTweet.entities.hashtags.length; ++i) {
      String tag = sourceTweet.entities.hashtags[i].text;
      int curStartIndex = fullText.indexOf('#$tag', lastMark);
      if (curStartIndex != -1) {
        lastMark = curStartIndex + tag.length + 1;
        hyperlinks.addAll({curStartIndex: Hyperlinks.tag});
        tagQueue.add(curStartIndex + tag.length + 1);
      }
    }
    var sortedKey = hyperlinks.keys.toList()..sort();

    // 最后标记的 index
    lastMark = 0;
    var spanList = List<TextSpan>();
    if (sortedKey.length != 0) {
      for (int index in sortedKey) {
        // 绘制上一个 hyperlinks 到 这个 hyperlinks 之间的内容
        if (index != lastMark)
          spanList.add(_buildCommonText(fullText.substring(lastMark, index), isDetail));
        switch (hyperlinks[index]) {
          case Hyperlinks.tag:
            spanList.add(_buildTagText(
                fullText.substring(index, lastMark = tagQueue.removeFirst()), isDetail));
            break;
          case Hyperlinks.mention:
            spanList.add(_buildMentionText(fullText.substring(
                index, lastMark = mentionQueue.removeFirst())));
            break;
          case Hyperlinks.url:
            spanList.add(_buildUrlText(
                fullText.substring(index, lastMark = urlQueue.removeFirst()), isDetail));
            break;
        }
        // 没有 hyperlinks 需要绘制直接绘制剩下的文本内容
        if (tagQueue.isEmpty &&
            urlQueue.isEmpty &&
            mentionQueue.isEmpty &&
            lastMark != fullText.length)
          spanList.add(
              _buildCommonText(fullText.substring(lastMark, fullText.length), isDetail));
      }
    } else {
      spanList.add(_buildCommonText(fullText, isDetail));
    }
    return Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text.rich(TextSpan(children: spanList)));
  }

  TextSpan _buildCommonText(String text, bool isDetail) {
    return TextSpan(
      text: text,
      style: isDetail ? TextStyleManager.black_83 : TextStyleManager.black_23,
    );
  }

  TextSpan _buildUrlText(String text, bool isDetail) {
    return TextSpan(
      text: text,
      style: isDetail ? TextStyleManager.blue_83 : TextStyleManager.blue_23,
    );
  }

  TextSpan _buildTagText(String text, bool isDetail) {
    return TextSpan(
      text: text,
      style: isDetail ? TextStyleManager.blue_83 : TextStyleManager.blue_23,
    );
  }

  TextSpan _buildMentionText(String text) {
    return TextSpan(
      text: text,
      style: isDetail ? TextStyleManager.blue_83 : TextStyleManager.blue_23,
    );
  }

  Widget get _media {
    if (sourceTweet.entities != null && sourceTweet.entities.media != null) {
      String mediaUrl = sourceTweet.entities.media[0].mediaUrlHttps;

      if (sourceTweet.entities.media[0].type == 'photo') {
        return _buildContentImage(mediaUrl, isDetail);
      } else {
        return Container();
      }
    } else
      return Container();
  }

  Widget get _options {
    return IconTheme(
      data: IconThemeData(color: Colors.grey, size: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildOptionItem(
              Icons.mode_comment_outlined, sourceTweet.replyCount.toString()),
          _buildOptionItem(
              Icons.repeat_outlined, sourceTweet.retweetCount.toString()),
          _buildOptionItem(
              Icons.favorite_outline, sourceTweet.favoriteCount.toString()),
          _buildOptionItem(Icons.share_outlined, ''),
          SizedBox(
            width: 1,
          )
        ],
      ),
    );
  }

  Widget get _title {
    return isDetail
        ? Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 0, 4),
              child: Column(
                children: [
                  Row(
                    children: [
                      _userName,
                      _extension,
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  _screenName
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          )
        : Row(
            children: [
              Expanded(
                child: _userName,
              ),
              _extension
            ],
            mainAxisSize: MainAxisSize.max,
          );
  }

  Widget get _extension {
    return IconButton(
      iconSize: 20,
      color: Colors.grey,
      icon: Icon(Icons.keyboard_arrow_down),
      onPressed: () {
        _showBottomSheet(sourceTweet);
      },
      padding: EdgeInsets.all(0),
      constraints: BoxConstraints(minHeight: 0, minWidth: 0),
      splashRadius: 24,
    );
  }

  Widget _buildOptionItem(IconData icon, String num) {
    return Row(
      children: [
        Padding(padding: EdgeInsets.all(4), child: Icon(icon)),
        Padding(
          padding: EdgeInsets.only(bottom: 2),
          child:
              Text(num == 'null' ? ' ' : num, style: TextStyleManager.grey_5),
        )
      ],
    );
  }

  Widget _buildHeadImage(String url) {
    return ClipOval(
        child: Image.network(
      url,
      height: 55,
      width: 55,
      fit: BoxFit.cover,
    ));
  }

  Widget _buildContentImage(String url, bool isDetail) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDetail ? 16 : 8),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: Image.network(
          url,
          height: isDetail ? 292 : 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<Void> _showBottomSheet(Tweet tweet) {
    User user = User.fromJson(isRetweeted
        ? tweet.retweetedStatus.user.toJson()
        : tweet.user.toJson());
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
    Future<void> future = Get.bottomSheet<void>(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 32,
              margin: EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                  color: Color(0xFFE5EDF0),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
            SimpleListTile(
              leading: Icon(Icons.sentiment_dissatisfied_rounded),
              title: Text(
                'Not interesting in this Tweet',
                style: TextStyleManager.black_47,
              ),
            ),
            SimpleListTile(
              leading: Icon(Icons.cancel_outlined),
              title: Text('Unfollow @${user.screenName}',
                  style: TextStyleManager.black_47),
            ),
            SimpleListTile(
              leading: Icon(Icons.volume_off_outlined),
              title: Text('Mute @${user.screenName}',
                  style: TextStyleManager.black_47),
            ),
            SimpleListTile(
              leading: Icon(Icons.block),
              title: Text('Block @${user.screenName}',
                  style: TextStyleManager.black_47),
            ),
            SimpleListTile(
              leading: Icon(Icons.flag_outlined),
              title: Text('Report Tweet', style: TextStyleManager.black_47),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        backgroundColor: Colors.white);
    future.then((value) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
          .copyWith(statusBarColor: Color(0xFFeaeaea)));
    });
    return null;
  }
}