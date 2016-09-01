(function () {
    $.Msg("subscribing");
    GameEvents.Subscribe("start_point_selector", function () {
        var hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
        var ability = Entities.GetAbilityByName(hero, "ds_point");
        if (ability == -1) {
            $.Msg("unable to find valid ability to execute for behavior" + cardBehavior + ", ability_name=" + ability_name);
            return;
        }
        $.Msg("begin to execute abilty");
        GameUI.SelectUnit(hero, false);
        Abilities.ExecuteAbility(ability, hero, false);
    });
})();
