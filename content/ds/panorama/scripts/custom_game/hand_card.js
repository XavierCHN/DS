var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
};
var HandCard = (function () {
    function HandCard(parent, id, uniqueId) {
        // 所显示的卡牌的ID
        this.card_id = -1;
        // 卡牌的唯一ID，在卡牌实例化的时候生成
        this.uniqueId = "";
        // 是否即将删除
        this.shouldRemove = false;
        this.card_id = id;
        this.uniqueId = uniqueId;
        this.panel = $.CreatePanel("Panel", parent, "");
        this.panel.BLoadLayoutSnippet("HandCard_Type" + GameUI.CustomUIConfig().AllCards[id].card_type); // 根据卡牌类型的不同，载入不同的snippet
        this.panel.SetPanelEvent("onmouseover", this.ShowHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseout", this.HideHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onactivate", this.OnClickCard.bind(this));
        $.Msg("New card instance is created, cardid=" + this.card_id + ", uniqueId = " + this.uniqueId);
    }
    HandCard.prototype.ShowHandCardTooltip = function () {
        $.Msg("Showing hand card tooltip, NOT IMPLEMENT YET!");
        $.Msg($.GetContextPanel());
    };
    HandCard.prototype.HideHandCardTooltip = function () {
        $.Msg("Hiding hand card tooltip, NOT IMPLEMENT YET!");
    };
    HandCard.prototype.OnClickCard = function () {
        $.Msg("On Click card, NOT IMPLEMENT YET!");
    };
    HandCard.prototype.Remove = function () {
        this.panel.DeleteAsync(0);
    };
    return HandCard;
}());
var AttributeCard = (function (_super) {
    __extends(AttributeCard, _super);
    function AttributeCard() {
        _super.apply(this, arguments);
    }
    return AttributeCard;
}(HandCard));
