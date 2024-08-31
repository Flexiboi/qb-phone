Config = Config or {}
Config.phoneItem = 'phone'
Config.vpnItem = 'vpn'
Config.BillingCommissions = { -- This is a percentage (0.10) == 10%
    mechanic = 0.10
}
Config.Linux = false      -- True if linux
Config.TweetDuration = 12 -- How many hours to load tweets (12 will load the past 12 hours of tweets)
Config.AdsDuration = 12
Config.RepeatTimeout = 2000
Config.CallRepeats = 10
Config.OpenPhone = 244
Config.MaxAdverts = 3
Config.DispatchJobLevel = 6
Config.PhoneApplications = {
    ['phone'] = {
        app = 'phone',
        color = 'c38641',
        icon = 'fa fa-phone-alt',
        tooltipText = 'Contact',
        tooltipPos = 'top',
        job = false,
        blockedjobs = {},
        slot = 1,
        Alerts = 0,
    },
    ['messageapp'] = {
        app = 'messageapp',
        color = '368051',
        icon = 'fas fa-comment',
        tooltipText = 'Bericht',
        tooltipPos = 'top',
        style = 'font-size: 2.8vh',
        job = false,
        blockedjobs = {},
        slot = 2,
        Alerts = 0,
    },
    ['settings'] = {
        app = 'settings',
        color = '6c8791',
        icon = 'fa fa-cogs',
        tooltipText = 'Settings',
        tooltipPos = 'top',
        style = 'padding-right: .08vh; font-size: 2.3vh',
        job = false,
        blockedjobs = {},
        slot = 3,
        Alerts = 0,
    },
    ['lawyers'] = {
        app = 'lawyers',
        color = 'a8a8a8',
        icon = 'fas fa-briefcase',
        tooltipText = 'Diensten',
        tooltipPos = 'bottom',
        job = false,
        blockedjobs = {},
        slot = 4,
        Alerts = 0,
    },
    ['bank'] = {
        app = 'bank',
        color = '9b5da3',
        icon = 'fas fa-money-check-alt',
        tooltipText = 'Bank',
        job = false,
        blockedjobs = {},
        slot = 5,
        Alerts = 0,
    },
    ['mail'] = {
        app = 'mail',
        color = '4E6876',
        icon = 'fas fa-envelope-open-text',
        tooltipText = 'Mail',
        job = false,
        blockedjobs = {},
        slot = 6,
        Alerts = 0,
    },
    ['twitter'] = {
        app = 'twitter',
        color = '42bcd2',
        icon = 'fab fa-twitter',
        tooltipText = 'Twatter',
        tooltipPos = 'top',
        job = false,
        blockedjobs = {},
        slot = 7,
        Alerts = 0,
    },
    ['advert'] = {
        app = 'advert',
        color = 'e2ca5f',
        icon = 'fas fa-bullhorn',
        tooltipText = 'Ads',
        job = false,
        blockedjobs = {},
        slot = 8,
        Alerts = 0,
    },
    ['houses'] = {
        app = 'houses',
        color = '52884e',
        icon = 'fas fa-home',
        tooltipText = 'Huizen',
        job = false,
        blockedjobs = {},
        slot = 9,
        Alerts = 0,
    },
    ['garage'] = {
        app = 'garage',
        color = '9c523f',
        icon = 'fas fa-car',
        tooltipText = 'Garage',
        job = false,
        blockedjobs = {},
        slot = 10,
        Alerts = 0,
    },
    ['tuner'] = {
        app = 'tuner',
        color = 'EC1919',
        icon = 'fas fa-car',
        tooltipText = 'Tuning',
        job = false,
        blockedjobs = {},
        slot = 11,
        Alerts = 0,
    },
    ['pings'] = {
        app = 'pings',
        color = 'E4DE4F',
        icon = 'fas fa-map-marked-alt',
        tooltipText = 'Ping',
        job = false,
        blockedjobs = {},
        slot = 12,
        Alerts = 0,
    },
    ['notes'] = {
        app = 'notes',
        color = 'a36e1e',
        icon = 'fas fa-sticky-note',
        tooltipText = 'Notes',
        job = false,
        blockedjobs = {},
        slot = 13,
        Alerts = 0,
    },
    ['camera'] = {
        app = 'camera',
        color = '3f3f3f',
        icon = 'fas fa-camera',
        tooltipText = 'Camera',
        tooltipPos = 'bottom',
        job = false,
        blockedjobs = {},
        slot = 14,
        Alerts = 0,
    },
    ['gallery'] = {
        app = 'gallery',
        color = '3f3f3f',
        icon = 'fas fa-images',
        tooltipText = 'Gallerij',
        tooltipPos = 'bottom',
        job = false,
        blockedjobs = {},
        slot = 15,
        Alerts = 0,
    },
    ['meos'] = {
        app = 'meos',
        color = '82623d',
        icon = 'fa-solid fa-building-shield',
        tooltipText = 'MDT',
        job = 'police',
        blockedjobs = {},
        slot = 16,
        Alerts = 0,
    },
}
Config.MaxSlots = 20

Config.StoreApps = {
}

Config.ringtoneFile = {
    sound = "./sounds/ringtone.ogg",
    muted = "./sounds/ringtone_buzz.ogg",
}

Config.NpcCalls = {
    ['911'] = {
        event = {
            type = 'server',
            trigger = 'qb-phone:server:Call911',
            args = {911},
            call = {
                time = 4, --seconds
                sound = 'hallometgert', -- InteractSound
            }
        },
    },
    ['6257831444'] = {
        event = {
            type = 'client',
            trigger = 'qb-drugs:client:cornerselling',
            args = {},
            call = {
                time = 4, --seconds
                sound = 'hallometgert', -- InteractSound
            }
        }
    }
}