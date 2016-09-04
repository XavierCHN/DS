function OnClickNo(){
    GameEvents.SendCustomGameEventToServer("ds_player_select", {
        PlayerID: Players.GetLocalPlayer(),
        result : "no",
    })
}

function OnClickYes(){
    GameEvents.SendCustomGameEventToServer("ds_player_select", {
        PlayerID: Players.GetLocalPlayer(),
        result : "yes",
    })
}

(function(){
    GameEvents.Subscribe("start_point_selector", function(args){
        $("#YesNoSelector").AddClass("Hidden");
        $("#TooltipLabel").RemoveClass("Hidden");

        $("#TooltipLabel").text = $.Localize(args.title);

        let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
        let ability = Entities.GetAbilityByName(hero, "ds_point");
        if(ability == -1) {
            // $.Msg(`unable to find valid ability to execute for behavior${cardBehavior}, ability_name=${ability_name}`);
            return;
        }
        // $.Msg(`begin to execute abilty`);
        GameUI.SelectUnit(hero, false);
        Abilities.ExecuteAbility(ability, hero, false);
    });

    GameEvents.Subscribe("start_unit_selector", function(args){
        $("#YesNoSelector").AddClass("Hidden");
        $("#TooltipLabel").RemoveClass("Hidden");

        $("#TooltipLabel").text = $.Localize(args.title);

        let hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
        let ability = Entities.GetAbilityByName(hero, "ds_single_target");
        if(ability == -1) {
            // $.Msg(`unable to find valid ability to execute for behavior${cardBehavior}, ability_name=${ability_name}`);
            return;
        }
        // $.Msg(`begin to execute abilty`);
        GameUI.SelectUnit(hero, false);
        Abilities.ExecuteAbility(ability, hero, false);
    })

    GameEvents.Subscribe("start_yes_no_selector", function(args){
        $("#TooltipLabel").AddClass("Hidden");
        $("#YesNoSelector").RemoveClass("Hidden");
        let title = $.Localize(args.title);
        if (args.title_args != undefined){
            for (let id in args.title_args){
                var reg = new RegExp(`{${id}}`, "g");
                title = title.replace(reg, args.title_args[id]);
            }
        }
        $("#SelectorMsg").text = title;
    });

    GameEvents.Subscribe("ds_clear_selector_message", function(){
        $("#TooltipLabel").AddClass("Hidden");
        $("#YesNoSelector").AddClass("Hidden");
    })
})();