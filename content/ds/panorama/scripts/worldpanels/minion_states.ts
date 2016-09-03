function UpdateMinionState() {
    let wp = $.GetContextPanel().WorldPanel;
    let offScreen = $.GetContextPanel().OffScreen;
    if (!offScreen && wp){
        let minion = wp.entity;
        if (minion){
            if (!Entities.IsAlive(minion)){
                $.GetContextPanel().style.opacity = "0";
                $.Schedule(1/30, UpdateMinionState)
                return;
            }
        }

        let team = Entities.GetTeamNumber(minion);
        let lteam = Players.GetTeam(Game.GetLocalPlayerID())
        if (team == lteam) {
            $.GetContextPanel().SetHasClass("Friendly", true);
        }else{
            $.GetContextPanel().SetHasClass("Friendly", false);
        }

        let atk = Entities.GetDamageMax(minion);
        let mhp = Entities.GetMaxHealth(minion);
        let hp = Entities.GetHealth(minion);

        $("#ATK_Label").text = atk;
        $("#HP_Label").text = hp;
        if (hp < mhp){
            $("#HP_Panel").SetHasClass("Hurt", true);
        }else{
            $("#HP_Panel").SetHasClass("Hurt", false);
        }
    }
    $.Schedule(1/30, UpdateMinionState);
}

(function(){
    UpdateMinionState()
})();