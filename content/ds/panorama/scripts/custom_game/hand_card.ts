class HandCard
{
    // 所显示的卡牌的ID
    card_id:number = -1;
    // 卡牌的唯一ID，在卡牌实例化的时候生成
    uniqueId:string = "";
    // 用以显示的panel
    panel: Panel;
    // 是否即将删除
    shouldRemove: boolean = false;

    constructor(parent:Panel, id: number, uniqueId: string){

        this.card_id = id;
        this.uniqueId = uniqueId;

        this.panel = $.CreatePanel("Panel", parent, "");
        
        this.panel.BLoadLayoutSnippet("HandCard_Type" + GameUI.CustomUIConfig().AllCards[id].card_type) // 根据卡牌类型的不同，载入不同的snippet

        this.panel.SetPanelEvent("onmouseover", this.ShowHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseout",  this.HideHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onactivate",  this.OnClickCard.bind(this));

        $.Msg(`New card instance is created, cardid=${this.card_id}, uniqueId = ${this.uniqueId}`)
    }

    ShowHandCardTooltip(){
        $.Msg("Showing hand card tooltip, NOT IMPLEMENT YET!");
        $.Msg($.GetContextPanel());
    }

    HideHandCardTooltip(){
        $.Msg("Hiding hand card tooltip, NOT IMPLEMENT YET!");
    }

    OnClickCard(){
        $.Msg("On Click card, NOT IMPLEMENT YET!");
    }

    Remove(){
        this.panel.DeleteAsync(0);
    }
}

class AttributeCard extends HandCard{
    
}