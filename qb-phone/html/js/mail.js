var OpenedMail = null;

$(document).on('click', '.mail', function(e){
    e.preventDefault();

    $(".mail-home").animate({
        left: 30+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: 0+"vh"
    }, 300);

    var MailData = $("#"+$(this).attr('id')).data('MailData');
    QB.Phone.Functions.SetupMail(MailData);

    OpenedMail = $(this).attr('id');
});

$(document).on('click', '.mail-back', function(e){
    e.preventDefault();

    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
    OpenedMail = null;
});

$(document).on('click', '#accept-mail', function(e){
    e.preventDefault();
    var MailData = $("#"+OpenedMail).data('MailData');
    $.post('https://qb-phone/AcceptMailButton', JSON.stringify({
        buttonEvent: MailData.button.buttonEvent,
        buttonData: MailData.button.buttonData,
        mailId: MailData.mailid,
    }));
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
});

$(document).on('click', '#remove-mail', function(e){
    e.preventDefault();
    var MailData = $("#"+OpenedMail).data('MailData');
    $.post('https://qb-phone/RemoveMail', JSON.stringify({
        mailId: MailData.mailid
    }));
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
});

QB.Phone.Functions.SetupMails = function(Mails) {
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewHour < 10) {
        Hourssssss = "0" + Hourssssss;
    }
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    var MessageTime = Hourssssss + ":" + Minutessss;

    $("#mail-header-mail").html(QB.Phone.Data.PlayerData.charinfo.firstname+"."+QB.Phone.Data.PlayerData.charinfo.lastname+"@mail.devinerp.be");
    // $("#mail-header-lastsync").html("Laatst gesynchroniseerd "+MessageTime);
    if (Mails !== null && Mails !== undefined) {
        if (Mails.length > 0) {
            $(".mail-list").html("");
            $.each(Mails, function(i, mail){
                var date = new Date(mail.date);
                var DateString = date.getDate()+" "+MonthFormatting[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();
                var element = '<div class="mail" id="mail-'+mail.mailid+'"><span class="mail-sender" style="font-weight: bold;">'+mail.sender+'</span> <div class="mail-text"><p>'+mail.message+'</p></div> <div class="mail-time">'+DateString+'</div></div>';

                $(".mail-list").append(element);
                $("#mail-"+mail.mailid).data('MailData', mail);
            });
        } else {
            $(".mail-list").html('<p class="nomails">Je hebt geen mails..</p>');
        }

    }
}

var MonthFormatting = ["Januari", "Februari", "Maart", "April", "Mei", "Juni", "Julie", "Augustus", "September", "Oktober", "November", "December"];

QB.Phone.Functions.SetupMail = function(MailData) {
    var date = new Date(MailData.date);
    var DateString = date.getDate()+" "+MonthFormatting[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();
    $(".mail-subject").html("<p><span style='font-weight: bold;'>"+MailData.sender+"</span><br>"+MailData.subject+"</p>");
    $(".mail-date").html("<p>"+DateString+"</p>");
    $(".mail-content").html("<p>"+MailData.message+"</p>");

    var AcceptElem = '<div class="opened-mail-footer-item" id="accept-mail"><i class="fas fa-check-circle mail-icon"></i></div>';
    var RemoveElem = '<div class="opened-mail-footer-item" id="remove-mail"><i class="fas fa-trash-alt mail-icon"></i></div>';
    
    $(".opened-mail-footer").html("");

    if (MailData.button !== undefined && MailData.button !== null) {
        $(".opened-mail-footer").append(AcceptElem);
        $(".opened-mail-footer").append(RemoveElem);
        $(".opened-mail-footer-item").css({"width":"50%"});
    } else {
        $(".opened-mail-footer").append(RemoveElem);
        $(".opened-mail-footer-item").css({"width":"100%"});
    }
}

// Advert JS

$(document).on('click', '.test-slet', function(e){
    e.preventDefault();
    $(".advert-home").animate({
        left: 30+"vh"
    });
    $(".new-advert").animate({
        left: 0+"vh"
    });
});

$(document).on('click','.advimage', function (){
    let source = $(this).attr('src')
    QB.Screen.popUp(source);
});

$(document).on('click','#new-advert-photo',function(e){
    e.preventDefault();
    $.post('https://qb-phone/TakePhoto',function(url){
        if(url){
            $('#advert-new-url').val(url)
        }
    })
    QB.Phone.Functions.Close();
});

$(document).on('click', '#new-advert-back', function(e){
    e.preventDefault();

    $(".advert-home").animate({
        left: 0+"vh"
    });
    $(".new-advert").animate({
        left: -30+"vh"
    });
});

$(document).on('click', '#new-advert-submit', function(e){
    e.preventDefault();
    var Advert = $(".new-advert-textarea").val();
    let picture = $('#advert-new-url').val();
    let category = $('#advert-new-category').val();
    if (Advert !== "") {
        $(".advert-home").animate({
            left: 0+"vh"
        });
        $(".new-advert").animate({
            left: -30+"vh"
        });
        if (!picture){
            $.post('https://qb-phone/PostAdvert', JSON.stringify({
                message: Advert,
                category: category,
                url: null
            }));
        }else {
            $.post('https://qb-phone/PostAdvert', JSON.stringify({
                message: Advert,
                category: category,
                url: picture
            }));
        }
        $('#advert-new-url').val("")
        $(".new-advert-textarea").val("");
    } else {
        QB.Phone.Notifications.Add("fas fa-ad", "Advertenties", "U kunt geen lege advertentie plaatsen!", "#ff8f1a", 2000);
    }
});

QB.Phone.Functions.RefreshAdverts = function(Adverts) {
    $("#advert-header-name").html("@"+QB.Phone.Data.PlayerData.charinfo.firstname+""+QB.Phone.Data.PlayerData.charinfo.lastname+" | "+QB.Phone.Data.PlayerData.charinfo.phone);
    if (Adverts.length > 0 || Adverts.length == undefined) {
        $(".advert-list").html("");
        $.each(Adverts, function(i, advert){
            if(advert.id != null) {
                var clean = DOMPurify.sanitize(advert.message , {
                    ALLOWED_TAGS: [],
                    ALLOWED_ATTR: []
                });
    
                var color = 'linear-gradient(to top, #e2ca5f 0%, #e4c53c 100%)';
                switch (advert.category) {
                    case 'item':
                        color = 'linear-gradient(to top, #e2ca5f 0%, #e4c53c 100%)';
                        break;
                    case 'car':
                        color = 'linear-gradient(to top, #ca4634 0%, #aa2c1b 100%)';
                        break;
                    case 'service':
                        color = 'linear-gradient(to top, #4fa2fa 0%, #2a6aaf 100%)';
                        break;
                    case 'other':
                        color = 'linear-gradient(to top, #faa44f 0%, #dd8731 100%)';
                        break;
                    default:
                        color = 'linear-gradient(to top, #e2ca5f 0%, #e4c53c 100%)';
                        break;
                }
    
                if (clean == '') { clean = 'Ik ben een gekke gans :/' }
                var element = '';
                if (advert.url) {
                    if (advert.number == QB.Phone.Data.PlayerData.charinfo.phone){
                        element = `<div class="advert" style="background:${color};" data-category='${advert.category}'><span class="advert-sender">${advert.name} </br><span class='advert-num' data-sender='${advert.name}' data-number='${advert.number}'> ${advert.number}</span></span><p class='advert-text'>${clean}</p></br><img class="advimage" src=`+advert.url +` style=" border-radius:4px; width: 95%; position:relative; z-index: 1; right:1px;height: auto; bottom:1vh;"></br><span><div class="adv-icon"></div> </span><i class="fas fa-trash"style="font-size: 1rem; right:0;" id="adv-delete" data-advertid='${advert.id}'></i></div>`;
                    } else {
                        element = `<div class="advert" style="background:${color};" data-category='${advert.category}'><span class="advert-sender">${advert.name} </br><span class='advert-num' data-sender='${advert.name}' data-number='${advert.number}'> ${advert.number}</span></span><p class='advert-text'>${clean}</p></br><img class="advimage" src=`+advert.url +` style=" border-radius:4px; width: 95%; position:relative; z-index: 1; right:1px;height: auto; bottom:1vh;"></br><span><div class="adv-icon"></div> </span></div>`;
                    }
                } else {
                    if (advert.number == QB.Phone.Data.PlayerData.charinfo.phone){
                        element = `<div class="advert" style="background:${color};" data-category='${advert.category}'><span class="advert-sender">${advert.name} </br><span class='advert-num' data-sender='${advert.name}' data-number='${advert.number}'> ${advert.number}</span></span><p class='advert-text'>${clean}</p><i class="fas fa-trash"style="font-size: 1rem; right:0;" id="adv-delete" data-advertid='${advert.id}'></i></div>`;
                    } else {
                        element = `<div class="advert" style="background:${color};" data-category='${advert.category}'><span class="advert-sender">${advert.name} </br><span class='advert-num' data-sender='${advert.name}' data-number='${advert.number}'> ${advert.number}</span></span><p class='advert-text'>${clean}</p></div>`;
                    }
                }
                $(".advert-list").append(element);
            }
        });
    } else {
        $(".advert-list").html("");
        var element = '<div class="advert"><span class="advert-sender">Er zijn nog geen advertenties..!</span></div>';
        $(".advert-list").append(element);
    }
}

$(document).on('click','#adv-delete',function(e){
    e.preventDefault();
    console.log($(this).data('advertid'))
    $.post('https://qb-phone/DeleteAdvert', JSON.stringify({
        id: $(this).data('advertid'),
    }));
    setTimeout(function(){
        QB.Phone.Notifications.Add("fas fa-ad", "Advertentie", "De advertentie werd verwijderd", "#ff8f1a", 2000);
    },400)
    $('#adv-delete').off('click');
})

$(document).on('click', '.advert-num', function(e){
    e.preventDefault();
    
    var cData = {
        number: $(this).data('number'),
        name: $(this).data('sender').replace('@','')
    }

    $.post('https://qb-phone/CallAdvert', JSON.stringify({
        ContactData: cData,
        Anonymous: QB.Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== QB.Phone.Data.PlayerData.charinfo.phone) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        if (QB.Phone.Data.AnonymousCall) {
                            QB.Phone.Notifications.Add("fas fa-phone", "Phone", "Je starte een anonieme oproep!");
                        }
                        $(".phone-call-outgoing").css({"display":"block"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(cData.name);
                        QB.Phone.Functions.HeaderTextColor("white", 400);
                        QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".lawyers-app").css({"display":"none"});
                            QB.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            QB.Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);
    
                        CallData.name = cData.name;
                        CallData.number = cData.number;
                    
                        QB.Phone.Data.currentApplication = "phone-call";
                    } else {
                        QB.Phone.Notifications.Add("fas fa-phone", "Phone", "U bent al verbonden met een oproep!");
                    }
                } else {
                    QB.Phone.Notifications.Add("fas fa-phone", "Phone", "Deze persoon is al in een oproep");
                }
            } else {
                QB.Phone.Notifications.Add("fas fa-phone", "Phone", "Deze persoon is niet beschikbaar!");
            }
        } else {
            QB.Phone.Notifications.Add("fas fa-phone", "Phone", "U kunt uw eigen nummer niet noemen!");
        }
    });
});
