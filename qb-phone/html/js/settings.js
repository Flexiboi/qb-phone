QB.Phone.Settings = {};
QB.Phone.Settings.Background = "#858484";
QB.Phone.Settings.OpenedTab = null;
QB.Phone.Settings.Backgrounds = {
    '#858484': {
        label: "Grijze",
        description: "Grijze Gradient",
    },
    '#ed930c': {
        label: "Oranje",
        description: "Oranje Gradient",
    },
    '#3aa440': {
        label: "Groen",
        description: "Groene Gradient",
    },
    '#3a5184': {
        label: "Blauw",
        description: "Blauwe Gradient",
    },
    '#84403a': {
        label: "Rood",
        description: "Rode Gradient",
    },
};

var PressedBackground = null;
var PressedBackgroundObject = null;
var OldBackground = null;
var IsChecked = null;

$(document).on('click', '.settings-app-tab', function(e){
    e.preventDefault();
    var PressedTab = $(this).data("settingstab");

    if (PressedTab == "background") {
        QB.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        QB.Phone.Settings.OpenedTab = PressedTab;
        $(".background-options").html('');
        var BackGrounds = null;
        Object.keys(QB.Phone.Settings.Backgrounds).forEach((value, index, self) => {
            BackGrounds += '<div class="background-option" data-background="'+value+'">' +
                '<div class="background-option-icon"> <i class="fas fa-paint-brush"></i> </div>' +
                '<div class="background-option-title"> '+QB.Phone.Settings.Backgrounds[value].label+' </div>'+
                '<div class="background-option-description">'+QB.Phone.Settings.Backgrounds[value].description+'</div></div>';
        })
        BackGrounds += '<div class="background-option" data-background="custom-background">'+
        '<div class="background-option-icon"><i class="fas fa-paint-brush"></i></div>'+
        '<div class="background-option-title">Custom</div>'+
        '<div class="background-option-description">Personalize your background</div></div>';
        $(".background-options").html(BackGrounds);
    } else if (PressedTab == "profilepicture") {
        QB.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        QB.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "numberrecognition") {
        var checkBoxes = $(".numberrec-box");
        QB.Phone.Data.AnonymousCall = !checkBoxes.prop("checked");
        checkBoxes.prop("checked", QB.Phone.Data.AnonymousCall);

        if (!QB.Phone.Data.AnonymousCall) {
            $("#numberrecognition > p").html('Uit');
        } else {
            $("#numberrecognition > p").html('Aan');
        }
    } else if (PressedTab == "phoneringtone") {
        var checkBoxes = $(".phonering-box");
        QB.Phone.Data.isMute = !checkBoxes.prop("checked");
        checkBoxes.prop("checked", QB.Phone.Data.isMute);

        if (!QB.Phone.Data.isMute) {
            $("#phoneringtone > p").html('Geluid');
            QB.Phone.Notifications.Add("fa-solid fa-volume-high", "Settings", "Je geluid staat weer aan!")
        } else {
            $("#phoneringtone > p").html('Stil');
            QB.Phone.Notifications.Add("fa-solid fa-volume-off", "Settings", "Je geluid staat uit!")
        }

        $.post('https://qb-phone/isMute', JSON.stringify({
            isMute: QB.Phone.Data.isMute,
        }))
    }
});

$(document).on('click', '#accept-background', function(e){
    e.preventDefault();
    var hasCustomBackground = QB.Phone.Functions.IsBackgroundCustom();

    if (hasCustomBackground === false) {
        QB.Phone.Notifications.Add("fas fa-paint-brush", "Settings", QB.Phone.Settings.Backgrounds[QB.Phone.Settings.Background].label+" is set!")
        QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
        if(QB.Phone.Settings.Background.includes('#')) {
            $(".phone-background").css({"background-image":"none"});
            $(".phone-background").css({"background":"linear-gradient(to top, "+QB.Phone.Settings.Background+" 0%, "+LightenDarkenColor(QB.Phone.Settings.Background,50)+" 100%)"});
        } else {
            $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+QB.Phone.Settings.Background+".png')"});
        }
    } else {
        QB.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal background set!")
        QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
        if(QB.Phone.Settings.Background.includes('#')) {
            $(".phone-background").css({"background-image":"none"});
            $(".phone-background").css({"background":"linear-gradient(to top, "+QB.Phone.Settings.Background+" 0%, "+LightenDarkenColor(QB.Phone.Settings.Background,-50)+" 100%)"});
        } else {
            $(".phone-background").css({"background-image":"url('"+QB.Phone.Settings.Background+"')"});
        }
    }

    $.post('https://qb-phone/SetBackground', JSON.stringify({
        background: QB.Phone.Settings.Background,
    }))
});

QB.Phone.Functions.LoadMetaData = function(MetaData) {
    if (MetaData.background !== null && MetaData.background !== undefined) {
        QB.Phone.Settings.Background = MetaData.background;
    } else {
        QB.Phone.Settings.Background = "#858484";
    }

    var hasCustomBackground = QB.Phone.Functions.IsBackgroundCustom();


    if (!hasCustomBackground) {
        if(QB.Phone.Settings.Background.includes('#')) {
            $(".phone-background").css({"background-image":"none"});
            $(".phone-background").css({"background":"linear-gradient(to top, #858484 0%, "+LightenDarkenColor('#858484',-50)+" 100%)"});
        } else {
            $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+QB.Phone.Settings.Background+".png')"});
        }
    } else {
        if(QB.Phone.Settings.Background.includes('#')) {
            $(".phone-background").css({"background-image":"none"});
            $(".phone-background").css({"background":"linear-gradient(to top, "+QB.Phone.Settings.Background+" 0%, "+LightenDarkenColor(QB.Phone.Settings.Background,-50)+" 100%)"});
        } else {
            $(".phone-background").css({"background-image":"url('"+QB.Phone.Settings.Background+")"});
        }
    }

    if (MetaData.profilepicture == "default") {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+MetaData.profilepicture+'">');
    }

    if (MetaData.isMute) {
        var checkBoxes = $(".phonering-box");
        checkBoxes.prop("checked", true);
        $("#phoneringtone > p").html('Stil');
    } else {
        var checkBoxes = $(".phonering-box");
        checkBoxes.prop("checked", false);
        $("#phoneringtone > p").html('Geluid');
    }
}

$(document).on('click', '#cancel-background', function(e){
    e.preventDefault();
    QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
});

QB.Phone.Functions.IsBackgroundCustom = function() {
    var retval = true;
    $.each(QB.Phone.Settings.Backgrounds, function(i, background){
        if (QB.Phone.Settings.Background == i) {
            retval = false;
        }
    });
    return retval
}

$(document).on('click', '.background-option', function(e){
    e.preventDefault();
    PressedBackground = $(this).data('background');
    PressedBackgroundObject = this;
    OldBackground = $(this).parent().find('.background-option-current');
    IsChecked = $(this).find('.background-option-current');

    if (IsChecked.length === 0) {
        if (PressedBackground != "custom-background") {
            QB.Phone.Settings.Background = PressedBackground;
            $(OldBackground).fadeOut(50, function(){
                $(OldBackground).remove();
            });
            $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            QB.Phone.Animations.TopSlideDown(".background-custom", 200, 13);
        }
    }
});

$(document).on('click', '#accept-custom-background', function(e){
    e.preventDefault();

    QB.Phone.Settings.Background = $(".custom-background-input").val();
    $(OldBackground).fadeOut(50, function(){
        $(OldBackground).remove();
    });
    $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
    QB.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

$(document).on('click', '#cancel-custom-background', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

// Profile Picture

var PressedProfilePicture = null;
var PressedProfilePictureObject = null;
var OldProfilePicture = null;
var ProfilePictureIsChecked = null;

$(document).on('click', '#accept-profilepicture', function(e){
    e.preventDefault();
    var ProfilePicture = QB.Phone.Data.MetaData.profilepicture;
    if (ProfilePicture === "default") {
        QB.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Standaard foto ingesteld!")
        QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        QB.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Persoonlijke foto ingsteld!")
        QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+ProfilePicture+'">');
    }
    $.post('https://qb-phone/UpdateProfilePicture', JSON.stringify({
        profilepicture: ProfilePicture,
    }));
});

$(document).on('click', '#accept-custom-profilepicture', function(e){
    e.preventDefault();
    QB.Phone.Data.MetaData.profilepicture = $(".custom-profilepicture-input").val();
    $(OldProfilePicture).fadeOut(50, function(){
        $(OldProfilePicture).remove();
    });
    $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
    QB.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});

$(document).on('click', '.profilepicture-option', function(e){
    e.preventDefault();
    PressedProfilePicture = $(this).data('profilepicture');
    PressedProfilePictureObject = this;
    OldProfilePicture = $(this).parent().find('.profilepicture-option-current');
    ProfilePictureIsChecked = $(this).find('.profilepicture-option-current');
    if (ProfilePictureIsChecked.length === 0) {
        if (PressedProfilePicture != "custom-profilepicture") {
            QB.Phone.Data.MetaData.profilepicture = PressedProfilePicture
            $(OldProfilePicture).fadeOut(50, function(){
                $(OldProfilePicture).remove();
            });
            $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            QB.Phone.Animations.TopSlideDown(".profilepicture-custom", 200, 13);
        }
    }
});

$(document).on('click', '#cancel-profilepicture', function(e){
    e.preventDefault();
    QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
});


$(document).on('click', '#cancel-custom-profilepicture', function(e){
    e.preventDefault();
    QB.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});

function LightenDarkenColor(col,amt) {
    var usePound = false;
    if ( col[0] == "#" ) {
        col = col.slice(1);
        usePound = true;
    }

    var num = parseInt(col,16);

    var r = (num >> 16) + amt;

    if ( r > 255 ) r = 255;
    else if  (r < 0) r = 0;

    var b = ((num >> 8) & 0x00FF) + amt;

    if ( b > 255 ) b = 255;
    else if  (b < 0) b = 0;
    
    var g = (num & 0x0000FF) + amt;

    if ( g > 255 ) g = 255;
    else if  ( g < 0 ) g = 0;

    return (usePound?"#":"") + (g | (b << 8) | (r << 16)).toString(16);
}