part of simple_chat;

class SimpleChat extends StatefulWidget {
  final List<ChatMessage> messages;
  final Function(ChatMessage) onSend;
  final ChatUser currentUser;
  final String dateFormat;

  final ScrollController scrollController;

  const SimpleChat({
    Key key,
    @required this.messages,
    @required this.onSend,
    @required this.currentUser,
    @required this.scrollController,
    this.dateFormat
  }) : super(key: key);

  @override
  _SimpleChatState createState() => _SimpleChatState();
}

class _SimpleChatState extends State<SimpleChat> {
  TextEditingController messageEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    print('_SimpleChatState.initState');
    Timer(
        Duration(milliseconds: 300),
        () => widget.scrollController.jumpTo(
              widget.scrollController.position.maxScrollExtent,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          widget.messages?.length != null
              ? Flexible(
                  child: ListView.builder(
                      itemCount: widget.messages.length,
                      controller: widget.scrollController,
                      //reverse: true,
                      itemBuilder: (context, index) {
                        return MessageTile(
                          message: widget.messages[index],
                          currentUser: widget.currentUser,
                          sendByMe: widget.currentUser.uid == widget.messages[index].user.uid,
                          dateFormat: widget.dateFormat,
                        );
                      }),
                )
              : Container(),
        ],
      ),
      bottomNavigationBar: Container(
          padding: MediaQuery.of(context).viewInsets,
          color: Colors.grey[300],
          child: Row(
            children: [
              Expanded(
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      onTap: () {
                        Timer(
                            Duration(milliseconds: 300),
                            () => widget.scrollController.animateTo(
                                  widget.scrollController.position.maxScrollExtent,
                                  curve: Curves.easeOut,
                                  duration: const Duration(milliseconds: 300),
                                ));
                      },
                      controller: messageEditingController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        hintText: 'Mesajınızı yazın...',
                      ),
                    )),
              ),
              GestureDetector(
                onTap: () {
                  widget.onSend(ChatMessage(text: messageEditingController.text, user: ChatUser()));
                  messageEditingController.clear();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.send,
                    color: Colors.purpleAccent,
                    size: 28,
                  ),
                ),
              ),
              SizedBox(
                width: 6,
              )
            ],
          )),
    );
  }
}

class MessageTile extends StatelessWidget {
  final ChatMessage message;
  final ChatUser currentUser;
  final bool sendByMe;
  final String dateFormat;

  MessageTile({@required this.message, this.currentUser, this.sendByMe, this.dateFormat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8, left: sendByMe ? 0 : 18, right: sendByMe ? 18 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe ? EdgeInsets.only(left: 22) : EdgeInsets.only(right: 22),
        padding: EdgeInsets.only(top: 13, bottom: 13, left: 17, right: 17),
        decoration: BoxDecoration(
            borderRadius: sendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(12))
                : BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
            color: sendByMe ? Color(0xff677fff) : Color(0xfff3f3f3)),
        child: Column(
          children: [
            RichText(
              textAlign: sendByMe ? TextAlign.end : TextAlign.start,
              text: TextSpan(
                text: message.text + '\n',
                style: TextStyle(
                  color: sendByMe ? Colors.white : Color(0xff2b2a2a),
                ),
                children: [
                  TextSpan(
                      text: DateFormat(dateFormat ?? 'dd-MM-yyyy HH:mm').format(message.createdAt).toString(),
                      style: TextStyle(
                        color: sendByMe ? Colors.white60 : Color(0xff8f8585),
                      )),
                ],
              ),
            ),
            /*   Text(message.text+""
                ""+DateFormat('yyyy-MM-dd').format(message.createdAt).toString(),
                textAlign: TextAlign.start,
                style: TextStyle(
                    color:sendByMe? Colors.white:Colors.black,
                    fontSize: 14,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300)),*/
          ],
        ),
      ),
    );
  }
}
