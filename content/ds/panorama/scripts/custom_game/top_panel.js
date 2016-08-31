var phase_end_time;
// let mana_panel = $("#ManaPanel");
var enemyhero;
var localhero;
function findEnemyHero() {
    for (var i = 0; i < 24; i++) {
        var hero = Players.GetPlayerHeroEntityIndex(i);
        if ((hero != localhero) && (hero != -1)) {
            enemyhero = hero;
            break;
        }
    }
}
function ShowAttributeTooltip(data) {
}
function UpdateHealthBar() {
    if (localhero == null || localhero == -1)
        localhero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var hp = Entities.GetHealth(localhero);
    var mhp = Entities.GetMaxHealth(localhero);
    $("#HealthValue").text = hp + "/" + mhp;
    $("#HealthBar").style.width = 100 * hp / mhp + "%";
    if (enemyhero == undefined)
        findEnemyHero();
    hp = Entities.GetHealth(enemyhero);
    mhp = Entities.GetMaxHealth(enemyhero);
    $("#Enemy_HealthValue").text = hp + "/" + mhp;
    $("#Enemy_HealthBar").style.width = 100 * hp / mhp + "%";
    $.Schedule(0.03, UpdateHealthBar);
}
function UpdatePhaseTimer() {
    if (phase_end_time == undefined) {
        $.Schedule(1, UpdatePhaseTimer);
        return;
    }
    var ct = Game.GetGameTime();
    var tr = phase_end_time - ct;
    var sec = Math.floor(tr);
    var msec = Math.floor((tr - sec) * 100);
    if (msec < 10)
        msec = "0" + msec;
    var timer = $("#PhaseTimer");
    timer.text = sec + "." + msec;
    if (sec < 5) {
        timer.SetHasClass("Near", true);
    }
    else {
        timer.SetHasClass("Near", false);
    }
    $.Schedule(0.03, UpdatePhaseTimer);
}
(function () {
    UpdatePhaseTimer();
    GameEvents.Subscribe("ds_new_phase", function (args) {
        var time = args.EndTime;
        phase_end_time = time;
        UpdatePhaseTimer();
        $("#PhaseIndicator").text = $.Localize("phase_" + args.NewPhase);
    });
    GameEvents.Subscribe("ds_turn_start", function (args) {
        var localplayer = Players.GetLocalPlayer();
        if (localplayer == args.PlayerID) {
            $("#RoundIndicator").text = $.Localize("#my_round");
        }
        else {
            $("#RoundIndicator").text = $.Localize("#enemy_round");
        }
    });
    UpdateHealthBar();
    GameEvents.Subscribe("ds_hero_data_changed", function (args) {
        if (localhero == undefined || localhero == -1)
            localhero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
        if (enemyhero == undefined || enemyhero == -1)
            findEnemyHero();
        var prefix = "";
        if (args.PlayerID == enemyhero) {
            prefix = "Enemy_";
        }
        if (args.Str > 0) {
            $("#" + prefix + "Str_Panel").RemoveClass("Hidden");
            $("#" + prefix + "StrValue").text = args.Str;
        }
        if (args.Agi > 0) {
            $("#" + prefix + "Agi_Panel").RemoveClass("Hidden");
            $("#" + prefix + "AgiValue").text = args.Agi;
        }
        if (args.Int > 0) {
            $("#" + prefix + "Int_Panel").RemoveClass("Hidden");
            $("#" + prefix + "IntValue").text = args.Int;
        }
        if (args.MaxMana > 0) {
            var mana_panel = $("#" + prefix + "ManaPanel");
            mana_panel.RemoveClass("Hidden");
            mana_panel.RemoveAndDeleteChildren();
            for (var i = 0; i < args.Mana; i++) {
                var new_panel = $.CreatePanel("Image", mana_panel, "");
                new_panel.SetImage("file://{images}/custom_game/top_panel/hero/mana_full.png");
                new_panel.AddClass("ManaBall");
                if (args.MaxMana > 12)
                    new_panel.AddClass("TooMuchLALALALALAA");
            }
            for (var i = 0; i < args.MaxMana - args.Mana; i++) {
                var new_panel = $.CreatePanel("Image", mana_panel, "");
                new_panel.SetImage("file://{images}/custom_game/top_panel/hero/mana_empty.png");
                new_panel.AddClass("ManaBall");
                if (args.MaxMana > 12)
                    new_panel.AddClass("TooMuchLALALALALAA");
            }
        }
    });
})();
