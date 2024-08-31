var CurrentAdvertTab = "advert-home"
var HashtagOpen = false;
var MinimumTrending = 100;

$(document).on('click', '.advert-header-tab', function(e){
    e.preventDefault();

    var PressedAdvertTab = $(this).data('adverttab');
    var PreviousAdvertTabObject = $('.advert-header').find('[data-adverttab="'+CurrentAdvertTab+'"]');

    if (PressedAdvertTab !== CurrentAdvertTab) {
        $(this).addClass('selected-advert-header-tab');
        $(PreviousAdvertTabObject).removeClass('selected-advert-header-tab');

        $("."+CurrentAdvertTab+"-tab").css({"display":"none"});
        $("."+PressedAdvertTab+"-tab").css({"display":"block"});

        if (PressedAdvertTab === "advert-mentions") {
            $.post('https://qb-phone/ClearMentions');
        }

        if (PressedAdvertTab == "advert-home") {
            $.post('https://qb-phone/GetAdverts', JSON.stringify({}), function(Adverts){
                QB.Phone.Notifications.LoadAdverts(Adverts);
            });
        }

        CurrentAdvertTab = PressedAdvertTab;

        if (HashtagOpen) {
            event.preventDefault();

            $(".advert-hashtag-Adverts").css({"left": "30vh"});
            $(".advert-hashtags").css({"left": "0vh"});
            $(".advert-new-Advert").css({"display":"block"});
            $(".advert-hashtags").css({"display":"block"});
            HashtagOpen = false;
        }
    } else if (CurrentAdvertTab == "advert-home" && PressedAdvertTab == "advert-home") {
        event.preventDefault();

        $.post('https://qb-phone/GetAdverts', JSON.stringify({}), function(Adverts){
            QB.Phone.Notifications.LoadAdverts(Adverts);
        });
    }
});

$(document).on('click', '.advert-new-Advert', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideDown(".advert-new-Advert-tab", 450, 0);
});

$(document).on('click', '#take-pic', function (e) {
    e.preventDefault();
    $.post('https://qb-phone/TakePhoto', JSON.stringify({}),function(url){
        if(url){
            $('#Advert-new-url').val(url)
        }
    })
    QB.Phone.Functions.Close();
})

QB.Phone.Notifications.LoadAdverts = function(Adverts) {
    Adverts = Adverts.reverse();
    if (Adverts !== null && Adverts !== undefined && Adverts !== "" && Adverts.length > 0) {
        $(".advert-home-tab").html("");
        $.each(Adverts, function(i, Advert){
            var clean = DOMPurify.sanitize(Advert.message , {
                ALLOWED_TAGS: [],
                ALLOWED_ATTR: []
            });
            if (clean == '') clean = 'Hmm, I shouldn\'t be able to do this...'
            var AdsMessage = QB.Phone.Functions.FormatAdvertMessage(clean);
            var TimeAgo = moment(Advert.date).format('MM/DD/YYYY hh:mm');

            var AdvertHandle = QB.Phone.Data.PlayerData.charinfo.phone
            var PictureUrl = "./img/default.png"
            if (Advert.picture !== "default") {
                PictureUrl = Advert.picture
            }

            if (Advert.url == "") {
                let AdvertElement = '<div id="'+Advert.AdsId+'"class="advert-Advert" data-twtname="'+Advert.firstName+' '+Advert.lastName+'" data-twtcid="'+Advert.citizenid+'" data-twtid ="'+Advert.AdsId+'" data-twthandler="' + AdvertHandle.replace(" ", "_") + '">' +
                    '<div class="ads-img" style="top: 0.5vh;"><img src="' + PictureUrl + '" class="Advertss-image"></div>'+
                    '<div class="advert-head">' + Advert.firstName + ' ' + Advert.lastName + ' &nbsp;<div class="pnumber"><i class="fas fa-phone"></i><div class="pnumber-number">' + AdvertHandle.replace(" ", "_")+'</div></div></div>' +
                    '<div class="advert-content"><div class="Advert-message">' + AdsMessage + '</div></div>' +
                    '<div class="advert-footer"><div class="ads-delete-click"><i class="fas fa-trash-can"></i></div>'+ TimeAgo +'</div></div>';
                    $(".advert-home-tab").append(AdvertElement);
            } else {
                let AdvertElement = '<div id ="'+Advert.AdsId+'"class="advert-Advert" data-twtname="'+Advert.firstName+' '+Advert.lastName+'" data-twtcid="'+Advert.citizenid+'" data-twtid ="'+Advert.AdsId+'" data-twthandler="' + AdvertHandle.replace(" ", "_") + '">' +
                    '<div class="ads-img" style="top: 0.5vh;"><img src="'+PictureUrl+'" class="Advertss-image"></div>' +
                    '<div class="advert-head">'+Advert.firstName+' '+Advert.lastName+' &nbsp;<div class="pnumber"><i class="fas fa-phone"></i><div class="pnumber-number">'+AdvertHandle.replace(" ", "_")+'</div></div></div>'+
                    '<div class="advert-content"><div class="Advert-message">'+AdsMessage+'</div>'+
                    '<img class="image" src= ' + Advert.url + ' style = " filter: blur(1.5px); border-radius: 4px;width: 70%; z-index: 1; height: auto; padding-bottom: 5px; filter:"></div>' +
                    '<div class="advert-footer"><div class="ads-delete-click"><i class="fas fa-trash-can"></i></div>'+ TimeAgo +'</div></div>';
                $(".advert-home-tab").append(AdvertElement);
            }
            // if (Advert.citizenid === QB.Phone.Data.PlayerData.citizenid){
            //     $(".Advert-message").append('<span><div class="ads-icon"><i class="fas fa-trash"style="position:absolute; right:2%; font-size: 1.5rem; z-index:4;" id ="ads-delete-click"></i></div>')
            // }
        });
    } else {
        $(".advert-home-tab").html('<div class="advert-no-Adverts"><p>Geen advertenties</p></div>');
    }
}

$(document).on('click','.ads-delete-click',function(e){
    e.preventDefault();
    let source = $(this).closest('.advert-Advert').data('twtid')
    let $this = $(this)
    $.post('https://qb-phone/DeleteAds', JSON.stringify({id: source}), function(status){
        if(status){
            $('#'+source).animate({
                left: "500px"
            }, 1500);
            setTimeout(function() {
                $this.closest('.advert-Advert').remove();
            }, 1500); 
        } else {
            QB.Phone.Notifications.Add("fas fa-ad", "Advertentie", "Ellah, Das niej u Advertentie hé!", "#ff8f1a", 2000);
        }
    })
})

$(document).on('click', '.pnumber', function(e){
    e.preventDefault();
    let data = $('.advert-Advert');
    var cData = {
        number: data.data('twthandler'),
        name: data.data('twtname')
    }
    var ContactData = cData;
    SetupAdCall(ContactData);
});


SetupAdCall = function(cData) {
    var retval = false;
    $.post('https://qb-phone/CallAds', JSON.stringify({
        ContactData: cData,
        Anonymous: QB.Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== QB.Phone.Data.PlayerData.charinfo.phone) {
            if (status.IsOnline) {
                $(".advert-app").css({"display":"none"});
                if (status.CanCall) {
                    if (!status.InCall) {
                        $(".phone-call-outgoing").css({"display":"block"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(cData.name);
                        QB.Phone.Functions.HeaderTextColor("white", 400);
                        QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".phone-app").css({"display":"none"});
                            QB.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            QB.Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);

                        CallData.name = cData.name;
                        CallData.number = cData.number;

                        QB.Phone.Data.currentApplication = "phone-call";
                    } else {
                        QB.Phone.Notifications.Add("fas fa-phone", "Telefoon", "Je bent al in een telefoontje!");
                    }
                } else {
                    QB.Phone.Notifications.Add("fas fa-phone", "Telefoon", "Deze persoon is druk!");
                }
            } else {
                QB.Phone.Notifications.Add("fas fa-phone", "Telefoon", "Deze persoon is niet beschikbaar!");
            }
        } else {
            QB.Phone.Notifications.Add("fas fa-phone", "Telefoon", "Je kunt jezelf niet bellen!");
        }
    });
}


$(document).on('click', '.Advert-reply', function(e){
    e.preventDefault();
    var TwtName = $(this).parent().data('twthandler');
    $('#Advert-new-url').val("");
    $("#Advert-new-message").val(TwtName + " ");
    QB.Phone.Animations.TopSlideDown(".advert-new-Advert-tab", 450, 0);
});

QB.Phone.Functions.FormatAdvertMessage = function(AdvertMessage) {
    var AdsMessage = AdvertMessage;
    var res = AdsMessage.split("@");
    var tags = AdsMessage.split("#");
    var InvalidSymbols = [
        "[",
        "?",
        "!",
        "@",
        "#",
        "]",
    ]

    for(i = 1; i < res.length; i++) {
        var MentionTag = res[i].split(" ")[0];
        if (MentionTag !== null && MentionTag !== undefined && MentionTag !== "") {
            AdsMessage = AdsMessage.replace(""+MentionTag, "<span class='mentioned-tag' data-mentiontag='"+MentionTag+"''>"+MentionTag+"</span>");
        }
    }

    for(i = 1; i < tags.length; i++) {
        var Hashtag = tags[i].split(" ")[0];

        for(i = 1; i < InvalidSymbols.length; i++){
            var symbol = InvalidSymbols[i];
            var res = Hashtag.indexOf(symbol);

            if (res > -1) {
                Hashtag = Hashtag.replace(symbol, "");
            }
        }

        if (Hashtag !== null && Hashtag !== undefined && Hashtag !== "") {
            AdsMessage = AdsMessage.replace("#"+Hashtag, "<span class='hashtag-tag-text' data-hashtag='"+Hashtag+"''>#"+Hashtag+"</span>");
        }
    }

    return AdsMessage
}

$(document).on('click', '#send-Advert', function(e){
    e.preventDefault();
    var AdvertMessage = $("#Advert-new-message").val();
    var imageURL = $('#Advert-new-url').val()
    if (AdvertMessage != "") {
        var CurrentDate = new Date();
        $.post('https://qb-phone/PostNewAdvert', JSON.stringify({
            Message: AdvertMessage,
            Date: CurrentDate,
            Picture: QB.Phone.Data.MetaData.profilepicture,
            url: imageURL
        }), function(Adverts){
            QB.Phone.Notifications.LoadAdverts(Adverts);
        });
        $.post('https://qb-phone/GetHashtags', JSON.stringify({}), function(Hashtags){
            QB.Phone.Notifications.LoadHashtags(Hashtags)
        })
        QB.Phone.Animations.TopSlideUp(".advert-new-Advert-tab", 450, -120);
    } else {
        QB.Phone.Notifications.Add("fab fa-advert", "Advert", "Fill a message!", "#1DA1F2");
    };
    $('#Advert-new-url').val("");
    $("#Advert-new-message").val("");
});

$(document).on('click', '#cancel-Advert', function(e){
    e.preventDefault();
    $('#Advert-new-url').html("");
    QB.Phone.Animations.TopSlideUp(".advert-new-Advert-tab", 450, -120);
});

$(document).on('click', '.image', function(e){
    e.preventDefault();
    let source = $(this).attr('src')
    QB.Screen.popUp(source)
});

$(document).on('click', '.mentioned-tag', function(e){
    e.preventDefault();
    CopyMentionTag(this);
});