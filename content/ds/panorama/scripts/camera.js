function LockCamera()
{

    var info = Game.GetLocalPlayerInfo()
    if(info.player_team_id == 2){
        GameUI.SetCameraTargetPosition( [0,-180,0], 0.1 );
    }else if(info.player_team_id == 3)
    {
        GameUI.SetCameraTargetPosition( [0,200,0], 0.1 );
        GameUI.SetCameraYaw(180);
    }else{
        GameUI.SetCameraPitchMin(90);
        GameUI.SetCameraPitchMax(90);
        GameUI.SetCameraTargetPosition([0,0,0], 0.1 )
    }
    GameUI.SetCameraDistance(1800);
    $.Schedule(0.1, LockCamera);
}

(function()
{
    LockCamera();
})();
GameUI.SetRenderBottomInsetOverride(0)
