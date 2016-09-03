function UpdateMinionState() {
    var wp = $.GetContextPanel().WorldPanel;
    var offScreen = $.GetContextPanel().OffScreen;
    if (!offScreen && wp) {
        var minion = wp.entity;
        if (minion) {
            if (!Entities.IsAlive(minion)) {
                $.GetContextPanel().style.opacity = "0";
                $.Schedule(1 / 30, UpdateMinionState);
                return;
            }
        }
        var team = Entities.GetTeamNumber(minion);
        var lteam = Players.GetTeam(Game.GetLocalPlayerID());
        if (team == lteam) {
            $.GetContextPanel().SetHasClass("Friendly", true);
        }
        else {
            $.GetContextPanel().SetHasClass("Friendly", false);
        }
        var atk = Entities.GetDamageMax(minion);
        var mhp = Entities.GetMaxHealth(minion);
        var hp = Entities.GetHealth(minion);
        $("#ATK_Label").text = atk;
        $("#HP_Label").text = hp;
        if (hp < mhp) {
            $("#HP_Panel").SetHasClass("Hurt", true);
        }
        else {
            $("#HP_Panel").SetHasClass("Hurt", false);
        }
    }
    $.Schedule(1 / 30, UpdateMinionState);
}
(function () {
    UpdateMinionState();
})();
