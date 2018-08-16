package com.pop136.puzzle.ui {
import com.pop136.puzzle.event.CommonDialogEvent;
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.manager.PopupManager;

import flash.display.Sprite;
import flash.events.FocusEvent;
import flash.events.MouseEvent;

import ui.CommonDialogMc;

public class CommonDialog extends Sprite {

    private var mc:CommonDialogMc;
    private var linkType:String;
    private var messager:Messager = Messager.getInstance();

    public function CommonDialog() {
        super();

        mc = new CommonDialogMc();
        addChild(mc);
        mc.descriptionTxt.text = '请输入图片描述';

        mc.closeBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            mc.brandTxt.text = '请输入品牌名';
            mc.descriptionTxt.text = '请输入图片描述';
            mc.linkTxt.text = '请输入链接';
            mc.linkTypeMc.txt.text = '链接类型';
            linkType = '0';
            PopupManager.hideCommonDialog();
        });

        mc.cancelBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            mc.brandTxt.text = '请输入品牌名';
            mc.descriptionTxt.text = '请输入图片描述';
            mc.linkTxt.text = '请输入链接';
            mc.linkTypeMc.txt.text = '链接类型';
            linkType = '0';
            PopupManager.hideCommonDialog();
        });

        mc.saveBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            var data = {
                brand:(mc.brandTxt.text!='' && mc.brandTxt.text!='请输入品牌名') ? mc.brandTxt.text : '',
                description:(mc.descriptionTxt.text!='' && mc.descriptionTxt.text!='请输入图片描述') ? mc.descriptionTxt.text : '',
                linkType:linkType,
                link:(mc.linkTxt.text!='' && mc.linkTxt.text!='请输入链接') ? mc.linkTxt.text : ''
            };
            messager.dispatchEvent(new CommonDialogEvent(CommonDialogEvent.SAVE, data));
            PopupManager.hideCommonDialog();
        });

        mc.brandTxt.addEventListener(FocusEvent.FOCUS_IN, function (e:FocusEvent) {
            if(mc.brandTxt.text=='请输入品牌名'){
                mc.brandTxt.text = '';
            }
        });
        mc.brandTxt.addEventListener(FocusEvent.FOCUS_OUT, function (e:FocusEvent) {
            if(mc.brandTxt.text==''){
                mc.brandTxt.text = '请输入品牌名';
            }
        });

        mc.descriptionTxt.addEventListener(FocusEvent.FOCUS_IN, function (e:FocusEvent) {
            if(mc.descriptionTxt.text=='请输入图片描述'){
                mc.descriptionTxt.text = '';
            }
        });
        mc.descriptionTxt.addEventListener(FocusEvent.FOCUS_OUT, function (e:FocusEvent) {
            if(mc.descriptionTxt.text==''){
                mc.descriptionTxt.text = '请输入图片描述';
            }
        });

        mc.linkTxt.addEventListener(FocusEvent.FOCUS_IN, function (e:FocusEvent) {
            if(mc.linkTxt.text=='请输入链接'){
                mc.linkTxt.text = '';
            }
        });
        mc.linkTxt.addEventListener(FocusEvent.FOCUS_OUT, function (e:FocusEvent) {
            if(mc.linkTxt.text==''){
                mc.linkTxt.text = '请输入链接';
            }
        });

        mc.linkTypeMc.txt.mouseEnabled = mc.linkTypeMc.optionMc.mc1.txt.mouseEnabled = mc.linkTypeMc.optionMc.mc2.txt.mouseEnabled = false;
        mc.linkTypeMc.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            if(e.target.name=='mc1' || e.target.name=='mc2'){
                linkType = e.target.name.substr(2,1);
                mc.linkTypeMc.txt.text = e.target.txt.text;
                mc.linkTypeMc.optionMc.visible = false;
                mc.linkTypeMc.statusMc.gotoAndStop('closed');
            }else{
                if(mc.linkTypeMc.optionMc.visible){
                    mc.linkTypeMc.statusMc.gotoAndStop('opened');
                }else{
                    mc.linkTypeMc.statusMc.gotoAndStop('closed');
                }
                mc.linkTypeMc.optionMc.visible = !mc.linkTypeMc.optionMc.visible;
            }
        });

    }

    public function setValue(brand:String="", description:String="", linkType:String="0", link:String=""){
        mc.brandTxt.text = brand!="" ? brand : '请输入品牌名';
        mc.descriptionTxt.text = description!="" ? description : '请输入图片描述';
        mc.linkTxt.text = link!="" ? link : '请输入链接';
        if(linkType=="0")mc.linkTypeMc.txt.text = '链接类型';
        if(linkType=="1")mc.linkTypeMc.txt.text = '网页';
        if(linkType=="2")mc.linkTypeMc.txt.text = '文件';
        this.linkType = linkType;
    }

}
}
