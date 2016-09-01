
(function(){
    $.Msg("subscribing")
    GameEvents.Subscribe("start_point_selector", function(){
        $("#YesNoSelector").AddClass("Hidden");
        let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
        let ability = Entities.GetAbilityByName(hero, "ds_point");
        if(ability == -1) {
            $.Msg(`unable to find valid ability to execute for behavior${cardBehavior}, ability_name=${ability_name}`);
            return;
        }
        $.Msg(`begin to execute abilty`);
        GameUI.SelectUnit(hero, false);
        Abilities.ExecuteAbility(ability, hero, false);
    });

    GameEvents.Subscribe("start_yes_no_selector", function(args){
        $("#TooltipLabel").AddClass("Hidden");

        $("#SelectorMsg").text = $.Localize(args.title);
        
    });
})();