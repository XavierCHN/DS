var phase_end_time: number;

var enemyhero:number;
var localhero:number;

function findEnemyHero(){
    for(let i = 0; i < 24; i ++){
        let hero = Players.GetPlayerHeroEntityIndex(i);
        if ( (hero != localhero) && (hero != -1) ){
            enemyhero = hero;
            break;
        }
    }
}

function ShowAttributeTooltip(data) {
    
}

function EndPhaseEarly() {
    GameEvents.SendCustomGameEventToServer("ds_player_end_phase", {
        PlayerID : Players.GetLocalPlayer(),
    })
}

function UpdateHealthBar(){
    if (localhero == null || localhero == -1)
        localhero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    if (localhero == null || localhero == -1) {
        $.Schedule(0.03, UpdateHealthBar);
        return;
    }
    let hp = Entities.GetHealth(localhero);
    let mhp = Entities.GetMaxHealth(localhero);

    $("#HealthValue").text = `${hp}/${mhp}`;
    $("#HealthBar").style.width = `${100 * hp/mhp}%`;
    
    if (enemyhero == undefined) findEnemyHero();
    if (enemyhero == null || enemyhero == -1){
        $.Schedule(0.03, UpdateHealthBar);
        return;
    };
    hp = Entities.GetHealth(enemyhero);
    mhp = Entities.GetMaxHealth(enemyhero);

    $("#Enemy_HealthValue").text = `${hp}/${mhp}`;
    $("#Enemy_HealthBar").style.width = `${100 * hp/mhp}%`;

    $.Schedule(0.03, UpdateHealthBar);

}

function UpdatePhaseTimer(){
    if (phase_end_time == undefined) 
    {
        $.Schedule(1, UpdatePhaseTimer);
        return;
    }

    let ct:number = Game.GetGameTime();
    let tr = phase_end_time - ct;
    if (tr >= 0 ){
        let sec = Math.floor(tr)
        let msec = Math.floor(( tr - sec ) * 100);
        if (msec < 10) msec = "0" + msec;
        let timer = $("#PhaseTimer")
        timer.text = `${sec}.${msec}`;
        if (sec < 5){
            timer.SetHasClass("Near", true);
        }else{
            timer.SetHasClass("Near", false);
        }
    }
    $.Schedule(0.03, UpdatePhaseTimer);
}

(function(){
    UpdatePhaseTimer();

    GameEvents.Subscribe("ds_new_phase", function(args)
    {
        let time = args.EndTime;
        phase_end_time = time;
        UpdatePhaseTimer();
        $("#PhaseIndicator").text = $.Localize(`phase_${args.NewPhase}`)
    })

    GameEvents.Subscribe("ds_turn_start", function(args){
        let localplayer = Players.GetLocalPlayer();
        if( localplayer == args.PlayerID){
            $("#RoundIndicator").text = $.Localize("#my_round");
        }else{
            $("#RoundIndicator").text = $.Localize("#enemy_round");
        }
    })

    UpdateHealthBar();

    GameEvents.Subscribe("ds_hero_data_changed", function(args){
        if (localhero == undefined || localhero == -1)
            localhero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
        if (enemyhero == undefined || enemyhero == -1)
            findEnemyHero();
        
        let prefix = ""
        if(args.PlayerID == enemyhero){
            prefix = "Enemy_"
        }

        if (args.Str > 0){
            $(`#${prefix}Str_Panel`).RemoveClass("Hidden");
            $(`#${prefix}StrValue`).text = args.Str;
        }
        if (args.Agi > 0){
            $(`#${prefix}Agi_Panel`).RemoveClass("Hidden");
            $(`#${prefix}AgiValue`).text = args.Agi;
        }
        if (args.Int > 0){
            $(`#${prefix}Int_Panel`).RemoveClass("Hidden");
            $(`#${prefix}IntValue`).text = args.Int;
        }

        if(args.MaxMana > 0){
            let mana_panel = $(`#${prefix}ManaPanel`);
            mana_panel.RemoveClass("Hidden")
            mana_panel.RemoveAndDeleteChildren();
            for(let i = 0; i <  args.Mana; i++){
                let new_panel = $.CreatePanel("Image", mana_panel, "");
                new_panel.SetImage("file://{images}/custom_game/top_panel/hero/mana_full.png");
                new_panel.AddClass("ManaBall");
                if(args.MaxMana > 12)
                    new_panel.AddClass("TooMuchLALALALALAA");
            }
            for(let i = 0; i < args.MaxMana - args.Mana; i++){
                let new_panel = $.CreatePanel("Image", mana_panel, "");
                new_panel.SetImage("file://{images}/custom_game/top_panel/hero/mana_empty.png");
                new_panel.AddClass("ManaBall");
                if(args.MaxMana > 12)
                    new_panel.AddClass("TooMuchLALALALALAA");
            }
        }
    })
})();
