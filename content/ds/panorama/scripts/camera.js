function SetupCamera() {

    var info = Game.GetLocalPlayerInfo()
    if (info.player_team_id == 2) {
        GameUI.SetCameraPitchMin(70);
        GameUI.SetCameraPitchMax(70);
        GameUI.SetCameraTargetPosition([0, -400, 0], 0.1);
    } else if (info.player_team_id == 3) {
        GameUI.SetCameraTargetPosition([0, 500, 0], 0.1);
        GameUI.SetCameraPitchMin(70);
        GameUI.SetCameraPitchMax(70);
        GameUI.SetCameraYaw(180);
    } else {
        GameUI.SetCameraPitchMin(90);
        GameUI.SetCameraPitchMax(90);
        GameUI.SetCameraTargetPosition([0, 0, 0], 0.1)
    }
    GameUI.SetCameraDistance(2300);

    $.Schedule(0.03, SetupCamera);
}

SetupCamera();

GameUI.SetRenderBottomInsetOverride(0)