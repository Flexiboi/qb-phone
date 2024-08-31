var messageappSearchActive = false;
var OpenedChatPicture = null;
var ExtraButtonsOpen = false;

$(document).ready(function(){
    $("#messageapp-search-input").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".messageapp-chats .messageapp-chat").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).on('click', '#messageapp-search-chats', function(e){
    e.preventDefault();

    if ($("#messageapp-search-input").css('display') == "none") {
        $("#messageapp-search-input").fadeIn(150);
        messageappSearchActive = true;
    } else {
        $("#messageapp-search-input").fadeOut(150);
        messageappSearchActive = false;
    }
});

$(document).on('click', '.messageapp-chat', function(e){
    e.preventDefault();

    var ChatId = $(this).attr('id');
    var ChatData = $("#"+ChatId).data('chatdata');

    QB.Phone.Functions.SetupChatMessages(ChatData);

    $.post('https://qb-phone/ClearAlerts', JSON.stringify({
        number: ChatData.number
    }));

    $("#messageapp-search-input").fadeOut(150);

    $(".messageapp-openedchat").css({"display":"block"});
    $(".messageapp-openedchat").animate({
        left: 0+"vh"
    },200);

    $(".messageapp-chats").animate({
        left: 30+"vh"
    },200, function(){
        $(".messageapp-chats").css({"display":"none"});
    });

    $('.messageapp-openedchat-messages').animate({scrollTop: 9999}, 150);

    if (OpenedChatPicture == null) {
        OpenedChatPicture = "./img/default.png";
        if (ChatData.picture != null || ChatData.picture != undefined || ChatData.picture != "default") {
            OpenedChatPicture = ChatData.picture
        }
        $(".messageapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
    }
});

$(document).on('click', '#messageapp-openedchat-back', function(e){
    e.preventDefault();
    $.post('https://qb-phone/GetmessageappChats', JSON.stringify({}), function(chats){
        QB.Phone.Functions.LoadmessageappChats(chats);
    });
    OpenedChatData.number = null;
    $(".messageapp-chats").css({"display":"block"});
    $(".messageapp-chats").animate({
        left: 0+"vh"
    }, 200);
    $(".messageapp-openedchat").animate({
        left: -30+"vh"
    }, 200, function(){
        $(".messageapp-openedchat").css({"display":"none"});
    });
    OpenedChatPicture = null;
});

QB.Phone.Functions.GetLastMessage = function(messages) {
    var CurrentDate = new Date();
    var CurrentMonth = CurrentDate.getMonth();
    var CurrentDOM = CurrentDate.getDate();
    var CurrentYear = CurrentDate.getFullYear();
    var LastMessageData = {
        time: "00:00",
        message: "Niets"
    }

    $.each(messages[messages.length - 1], function(i, msg){
        var msgData = msg[msg.length - 1];
        LastMessageData.time = msgData.time
        LastMessageData.message = DOMPurify.sanitize(msgData.message , {
            ALLOWED_TAGS: [],
            ALLOWED_ATTR: []
        });
        if(LastMessageData.message == '') 'Mag ik dit wel doen..?'
    });

    return LastMessageData
}

GetCurrentDateKey = function() {
    var CurrentDate = new Date();
    var CurrentMonth = CurrentDate.getMonth();
    var CurrentDOM = CurrentDate.getDate();
    var CurrentYear = CurrentDate.getFullYear();
    var CurDate = ""+CurrentDOM+"-"+CurrentMonth+"-"+CurrentYear+"";

    return CurDate;
}

QB.Phone.Functions.LoadmessageappChats = function(chats) {
    $(".messageapp-chats").html("");
    $("#messageapp-search-input").fadeIn(150);
    $.each(chats, function(i, chat){
        var profilepicture = "./img/default.png";
        if (chat.picture !== "default") {
            profilepicture = chat.picture
        }
        var LastMessage = QB.Phone.Functions.GetLastMessage(chat.messages);
        var ChatElement = '<div class="messageapp-chat" id="messageapp-chat-'+i+'"><div class="messageapp-chat-picture" style="background-image: url('+profilepicture+');"></div><div class="messageapp-chat-name"><p>'+chat.name+'</p></div><div class="messageapp-chat-lastmessage"><p>'+LastMessage.message+'</p></div> <div class="messageapp-chat-lastmessagetime"><p>'+LastMessage.time+'</p></div><div class="messageapp-chat-unreadmessages unread-chat-id-'+i+'">1</div></div>';

        $(".messageapp-chats").append(ChatElement);
        $("#messageapp-chat-"+i).data('chatdata', chat);

        if (chat.Unread > 0 && chat.Unread !== undefined && chat.Unread !== null) {
            $(".unread-chat-id-"+i).html(chat.Unread);
            $(".unread-chat-id-"+i).css({"display":"block"});
        } else {
            $(".unread-chat-id-"+i).css({"display":"none"});
        }
    });
}

QB.Phone.Functions.ReloadmessageappAlerts = function(chats) {
    $.each(chats, function(i, chat){
        if (chat.Unread > 0 && chat.Unread !== undefined && chat.Unread !== null) {
            $(".unread-chat-id-"+i).html(chat.Unread);
            $(".unread-chat-id-"+i).css({"display":"block"});
        } else {
            $(".unread-chat-id-"+i).css({"display":"none"});
        }
    });
}

const monthNames = ["Januari", "Februari", "Maart", "april", "Mei", "juni", "Juli", "augustus", "september", "oktober", "november", "december"];

FormatChatDate = function(date) {
    var TestDate = date.split("-");
    var NewDate = new Date((parseInt(TestDate[1]) + 1)+"-"+TestDate[0]+"-"+TestDate[2]);

    var CurrentMonth = monthNames[NewDate.getMonth()];
    var CurrentDOM = NewDate.getDate();
    var CurrentYear = NewDate.getFullYear();
    var CurDateee = CurrentDOM + "-" + NewDate.getMonth() + "-" + CurrentYear;
    var ChatDate = CurrentDOM + " " + CurrentMonth + " " + CurrentYear;
    var CurrentDate = GetCurrentDateKey();

    var ReturnedValue = ChatDate;
    if (CurrentDate == CurDateee) {
        ReturnedValue = "Vandaag";
    }

    return ReturnedValue;
}

FormatMessageTime = function() {
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    if (NewHour < 10) {
        Hourssssss = "0" + NewHour;
    }
    var MessageTime = Hourssssss + ":" + Minutessss
    return MessageTime;
}

$(document).on('click', '#messageapp-openedchat-send', function(e){
    e.preventDefault();

    var Message = $("#messageapp-openedchat-message").val();

    if (Message !== null && Message !== undefined && Message !== "") {
        $.post('https://qb-phone/SendMessage', JSON.stringify({
            ChatNumber: OpenedChatData.number,
            ChatDate: GetCurrentDateKey(),
            ChatMessage: Message,
            ChatTime: FormatMessageTime(),
            ChatType: "message",
        }));
        $("#messageapp-openedchat-message").val("");
        // $("div.emojionearea-editor").data("emojioneArea").setText('');
    } else {
        QB.Phone.Notifications.Add("fab fa-messageapp", "messageapp", "Je kan geen leeg bericht versturen!", "#619b63", 1750);
    }
});

$(document).on('keypress', function (e) {
    if (OpenedChatData.number !== null) {
        if(e.which === 13){
            var Message = $("#messageapp-openedchat-message").val();

            if (Message !== null && Message !== undefined && Message !== "") {
                var clean = DOMPurify.sanitize(Message , {
                    ALLOWED_TAGS: [],
                    ALLOWED_ATTR: []
                });
                if (clean == '') clean = 'Hmm, ik zou dit niet moeten kunnen doen...'
                $.post('https://qb-phone/SendMessage', JSON.stringify({
                    ChatNumber: OpenedChatData.number,
                    ChatDate: GetCurrentDateKey(),
                    ChatMessage: clean,
                    ChatTime: FormatMessageTime(),
                    ChatType: "message",
                }));
                $("#messageapp-openedchat-message").val("");
            } else {
                QB.Phone.Notifications.Add("fab fa-messageapp", "messageapp", "Je kan geen leeg bericht versturen!", "#619b63", 1750);
            }
        }
    }
});

$(document).on('click', '#send-location', function(e){
    e.preventDefault();

    $.post('https://qb-phone/SendMessage', JSON.stringify({
        ChatNumber: OpenedChatData.number,
        ChatDate: GetCurrentDateKey(),
        ChatMessage: "Shared location",
        ChatTime: FormatMessageTime(),
        ChatType: "location",
    }));
});

$(document).on('click', '#send-image', function(e){
    e.preventDefault();
    let ChatNumber2 = OpenedChatData.number;
    $.post('https://qb-phone/TakePhoto', JSON.stringify({}),function(url){
        if(url){
        $.post('https://qb-phone/SendMessage', JSON.stringify({
        ChatNumber: ChatNumber2,
        ChatDate: GetCurrentDateKey(),
        ChatMessage: "Photo",
        ChatTime: FormatMessageTime(),
        ChatType: "picture",
        url : url
    }))}})
    QB.Phone.Functions.Close();
});

QB.Phone.Functions.SetupChatMessages = function(cData, NewChatData) {
    if (cData) {
        OpenedChatData.number = cData.number;

        if (OpenedChatPicture == null) {
            $.post('https://qb-phone/GetProfilePicture', JSON.stringify({
                number: OpenedChatData.number,
            }), function(picture){
                OpenedChatPicture = "./img/default.png";
                if (picture != "default" && picture != null) {
                    OpenedChatPicture = picture
                }
                $(".messageapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
            });
        } else {
            $(".messageapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
        }

        $(".messageapp-openedchat-name").html("<p>"+cData.name+"</p>");
        $(".messageapp-openedchat-messages").html("");

        $.each(cData.messages, function(i, chat){

            var ChatDate = FormatChatDate(chat.date);
            var ChatDiv = '<div class="messageapp-openedchat-messages-'+i+' unique-chat"><div class="messageapp-openedchat-date">'+ChatDate+'</div></div>';

            $(".messageapp-openedchat-messages").append(ChatDiv);

            $.each(cData.messages[i].messages, function(index, message){
                message.message = DOMPurify.sanitize(message.message , {
                    ALLOWED_TAGS: [],
                    ALLOWED_ATTR: []
                });
                if (message.message == '') message.message = 'Hmm, ik zou dit niet moeten kunnen doen...'
                var Sender = "me";
                if (message.sender !== QB.Phone.Data.PlayerData.citizenid) { Sender = "andere"; }
                var MessageElement
                if (message.type == "message") {
                    MessageElement = '<div class="messageapp-openedchat-message messageapp-openedchat-message-'+Sender+'">'+message.message+'<div class="messageapp-openedchat-message-time">'+message.time+'</div></div><div class="clearfix"></div>'
                } else if (message.type == "location") {
                    MessageElement = '<div class="messageapp-openedchat-message messageapp-openedchat-message-'+Sender+' messageapp-shared-location" data-x="'+message.data.x+'" data-y="'+message.data.y+'"><span style="font-size: 1.2vh;"><i class="fas fa-map-marker-alt" style="font-size: 1vh;"></i> Plaats</span><div class="messageapp-openedchat-message-time">'+message.time+'</div></div><div class="clearfix"></div>'
                } else if (message.type == "picture") {
                    MessageElement = '<div class="messageapp-openedchat-message messageapp-openedchat-message-'+Sender+'" data-id='+OpenedChatData.number+'><img class="wppimage" src='+message.data.url +'  style=" border-radius:4px; width: 100%; position:relative; z-index: 1; right:1px;height: auto;"></div><div class="messageapp-openedchat-message-time">'+message.time+'</div></div><div class="clearfix"></div>'
                }
                $(".messageapp-openedchat-messages-"+i).append(MessageElement);
            });
        });
        $('.messageapp-openedchat-messages').animate({scrollTop: 9999}, 1);
    } else {
        OpenedChatData.number = NewChatData.number;
        if (OpenedChatPicture == null) {
            $.post('https://qb-phone/GetProfilePicture', JSON.stringify({
                number: OpenedChatData.number,
            }), function(picture){
                OpenedChatPicture = "./img/default.png";
                if (picture != "default" && picture != null) {
                    OpenedChatPicture = picture
                }
                $(".messageapp-openedchat-picture").css({"background-image":"url("+OpenedChatPicture+")"});
            });
        }

        $(".messageapp-openedchat-name").html("<p>"+NewChatData.name+"</p>");
        $(".messageapp-openedchat-messages").html("");
        var NewDate = new Date();
        var NewDateMonth = NewDate.getMonth();
        var NewDateDOM = NewDate.getDate();
        var NewDateYear = NewDate.getFullYear();
        var DateString = ""+NewDateDOM+"-"+(NewDateMonth+1)+"-"+NewDateYear;
        var ChatDiv = '<div class="messageapp-openedchat-messages-'+DateString+' unique-chat"><div class="messageapp-openedchat-date">VANDAAG</div></div>';

        $(".messageapp-openedchat-messages").append(ChatDiv);
    }

    $('.messageapp-openedchat-messages').animate({scrollTop: 9999}, 1);
}

$(document).on('click', '.messageapp-shared-location', function(e){
    e.preventDefault();
    var messageCoords = {}
    messageCoords.x = $(this).data('x');
    messageCoords.y = $(this).data('y');

    $.post('https://qb-phone/SharedLocation', JSON.stringify({
        coords: messageCoords,
    }))
});

$(document).on('click', '.wppimage', function(e){
    e.preventDefault();
    let source = $(this).attr('src')
   QB.Screen.popUp(source)
});

$(document).on('click', '#messageapp-openedchat-message-extras', function(e){
    e.preventDefault();

    if (!ExtraButtonsOpen) {
        $(".messageapp-extra-buttons").css({"display":"block"}).animate({
            top: -15+"vh"
        }, 250);
        ExtraButtonsOpen = true;
    } else {
        $(".messageapp-extra-buttons").animate({
            top: 0+"vh"
        }, 250, function(){
            $(".messageapp-extra-buttons").css({"display":"block"});
            ExtraButtonsOpen = false;
        });
    }
});
