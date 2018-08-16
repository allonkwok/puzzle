package com.pop136.puzzle.manager {
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.event.TemplateListEvent;
import com.pop136.puzzle.event.TopBarEvent;
import com.pop136.puzzle.ui.CommonDialog;
import com.pop136.puzzle.ui.LayerDialog;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;

import ui.BigPhotoMc;
import ui.ConfirmDialogMc;
import ui.HolderMc;
import ui.SaveDialogMc;

public class PopupManager {

    public static var maskerMc:HolderMc;
    public static var bigPhotoMc:BigPhotoMc;
    public static var layoutDialog:LayerDialog;
    public static var commonDialog:CommonDialog;
    public static var saveDialogMc:SaveDialogMc;
    public static var confirmDialogMc:ConfirmDialogMc;
    private static var stage:Stage;
    private static var messager:Messager = Messager.getInstance();

    public static function init(stage:Stage) {
        PopupManager.stage = stage;
        maskerMc = new HolderMc();
        maskerMc.visible = false;

        bigPhotoMc = new BigPhotoMc();
        bigPhotoMc.visible = false;
        bigPhotoMc.btn.addEventListener(MouseEvent.CLICK, function () {
            hideBig();
        });

        layoutDialog = new LayerDialog();
        layoutDialog.visible = false;

        commonDialog = new CommonDialog();
        commonDialog.visible = false;

        saveDialogMc = new SaveDialogMc();
        saveDialogMc.visible = false;
        saveDialogMc.btn.addEventListener(MouseEvent.CLICK, function () {
            hideSaveDialog();
        });

        confirmDialogMc = new ConfirmDialogMc();
        confirmDialogMc.visible = false;
        confirmDialogMc.btn.addEventListener(MouseEvent.CLICK, function () {
            hideConfirmDialog();
        });
        confirmDialogMc.confirmBtn.addEventListener(MouseEvent.CLICK, function () {
            if(confirmDialogMc.txt.text=='是否取消编辑？'){
                messager.dispatchEvent(new TemplateListEvent(TemplateListEvent.CONFIRM));
            }else if(confirmDialogMc.txt.text=='是否删除此设计？'){
                messager.dispatchEvent(new TopBarEvent(TopBarEvent.CONFIRM));
            }
        });
        confirmDialogMc.cancelBtn.addEventListener(MouseEvent.CLICK, function () {
            hideConfirmDialog();
        });

    }

    public static function showBig(url:String){
        maskerMc.width = stage.stageWidth;
        maskerMc.height = stage.stageHeight;
        maskerMc.visible = true;
        bigPhotoMc.x = (stage.stageWidth - bigPhotoMc.width)/2;
        bigPhotoMc.y = (stage.stageHeight - bigPhotoMc.height)/2;
        bigPhotoMc.visible = true;
        bigPhotoMc.container.removeChildren();
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBigLoaded);
        loader.load(new URLRequest(url));
        stage.addChild(maskerMc);
        stage.addChild(bigPhotoMc);
    }

    public static function hideBig():void{
        maskerMc.visible = false;
        bigPhotoMc.container.removeChildren();
        bigPhotoMc.visible = false;
        stage.removeChild(maskerMc);
        stage.removeChild(bigPhotoMc);
    }

    private static function onBigLoaded(e:Event):void{
        var bmp:Bitmap = e.target.content as Bitmap;
        bmp.smoothing = true;
        bigPhotoMc.container.addChild(bmp);
        if(bmp.width>bmp.height){
            var rate = 480/bmp.width;
            bmp.width = 480;
            bmp.height = bmp.height*rate;
            bmp.y = (480-bmp.height)/2;
        }else{
            var rate = 480/bmp.height;
            bmp.width = bmp.width*rate;
            bmp.height = 480;
            bmp.x = (480-bmp.width)/2;
        }
    }

    public static function showLayerDialog():void{
        maskerMc.width = stage.stageWidth;
        maskerMc.height = stage.stageHeight;
        maskerMc.visible = true;
        layoutDialog.x = (stage.stageWidth - layoutDialog.width)/2;
        layoutDialog.y = (stage.stageHeight - layoutDialog.height)/2;
        layoutDialog.visible = true;
        layoutDialog.reset();
        stage.addChild(maskerMc);
        stage.addChild(layoutDialog);
    }

    public static function hideLayerDialog():void{
        maskerMc.visible = false;
        layoutDialog.visible = false;
        stage.removeChild(maskerMc);
        stage.removeChild(layoutDialog);
    }

    public static function showCommonDialog(brand:String, description:String, linkType:String, link:String):void{
        maskerMc.width = stage.stageWidth;
        maskerMc.height = stage.stageHeight;
        maskerMc.visible = true;
        commonDialog.x = (stage.stageWidth - commonDialog.width)/2;
        commonDialog.y = (stage.stageHeight - commonDialog.height)/2;
        commonDialog.visible = true;
        commonDialog.setValue(brand,description,linkType,link);
        stage.addChild(maskerMc);
        stage.addChild(commonDialog);
    }

    public static function hideCommonDialog():void{
        maskerMc.visible = false;
        commonDialog.visible = false;
        commonDialog.setValue();
        stage.removeChild(maskerMc);
        stage.removeChild(commonDialog);
    }

    public static function showSaveDialog(str:String="", hasBtn:Boolean=true):void{
        if(hasBtn){
            saveDialogMc.btn.visible = true;
        }else{
            saveDialogMc.btn.visible = false;
        }
        maskerMc.width = stage.stageWidth;
        maskerMc.height = stage.stageHeight;
        maskerMc.visible = true;
        saveDialogMc.x = (stage.stageWidth - saveDialogMc.width)/2;
        saveDialogMc.y = (stage.stageHeight - saveDialogMc.height)/2;
        saveDialogMc.visible = true;
        saveDialogMc.txt.text = str;
        if(!stage.contains(maskerMc)){
            stage.addChild(maskerMc);
        }
        if(!stage.contains(saveDialogMc)){
            stage.addChild(saveDialogMc);
        }
    }

    public static function hideSaveDialog():void{
        maskerMc.visible = false;
        layoutDialog.visible = false;
        stage.removeChild(maskerMc);
        stage.removeChild(saveDialogMc);
    }

    public static function showConfirmDialog(str:String=""):void{
        maskerMc.width = stage.stageWidth;
        maskerMc.height = stage.stageHeight;
        maskerMc.visible = true;
        confirmDialogMc.txt.text = (str!="") ? str : confirmDialogMc.txt.text;
        confirmDialogMc.x = (stage.stageWidth - confirmDialogMc.width)/2;
        confirmDialogMc.y = (stage.stageHeight - confirmDialogMc.height)/2;
        confirmDialogMc.visible = true;
        stage.addChild(maskerMc);
        stage.addChild(confirmDialogMc);
    }

    public static function hideConfirmDialog():void{
        maskerMc.visible = false;
        confirmDialogMc.visible = false;
        stage.removeChild(maskerMc);
        stage.removeChild(confirmDialogMc);
    }

}
}
