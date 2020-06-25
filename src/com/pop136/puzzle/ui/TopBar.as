package com.pop136.puzzle.ui {
import com.pop136.puzzle.Config;
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.event.OperationEvent;
import com.pop136.puzzle.event.TopBarEvent;
import com.pop136.puzzle.manager.DataManager;
import com.pop136.puzzle.manager.PopupManager;
import com.pop136.puzzle.manager.ServiceManager;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.utils.setTimeout;

import ui.SaveBtn;

import ui.SubmitBtn;
import ui.TabBtn;
import ui.TabMc;
import ui.UndoBtn;
import ui.RedoBtn;

public class TopBar extends Sprite{

    private var submitBtn:SubmitBtn;
    private var saveBtn:SaveBtn;
    public var tabBtn:TabBtn;
    private var undoBtn:UndoBtn;
    public var redoBtn:RedoBtn;
    private var container:Sprite;
    private var messager:Messager = Messager.getInstance();
    private var currentTab:TabMc;

    public function TopBar() {

        container = new Sprite();
        addChild(container);

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

    }

    private function onAddedToStage(e:Event):void{
        this.graphics.lineStyle(1, Config.GRAY);
        this.graphics.beginFill(0xffffff);
        this.graphics.drawRect(0, 0, stage.stageWidth, 40);
        this.graphics.endFill();

        var tab:TabMc = new TabMc();
        tab.x = Config.GAP;
        tab.y = Config.GAP;
        tab.tmpid = 1;
        tab.name = "tab1";
        tab.txt.text = "设计1";
        tab.txt.type
        tab.btn.visible = false;
        tab.txt.x = 15;
        tab.gotoAndStop("active");
        tab.buttonMode = true;
        container.addChild(tab);

        tabBtn = new TabBtn();
        tabBtn.x = container.x + container.width + Config.GAP;
        tabBtn.y = Config.GAP;
        addChild(tabBtn);

        submitBtn = new SubmitBtn();
        submitBtn.x = stage.stageWidth-submitBtn.width;
        addChild(submitBtn);

        saveBtn = new SaveBtn();
        saveBtn.x = submitBtn.x - saveBtn.width;
        addChild(saveBtn);

        redoBtn = new RedoBtn();
        redoBtn.x = saveBtn.x - redoBtn.width;
        redoBtn.gotoAndStop('disabled');
        addChild(redoBtn);

        undoBtn = new UndoBtn();
        undoBtn.x = redoBtn.x - undoBtn.width;
        undoBtn.gotoAndStop('disabled');
        addChild(undoBtn);

        stage.addEventListener(Event.RESIZE, onResize);

        addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
//        addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        addEventListener(MouseEvent.CLICK, onClick);
        messager.addEventListener(TopBarEvent.CONFIRM, onConfirm);
        messager.addEventListener(TopBarEvent.AFTER_SAVE_OPERATION, onAfterSaveOperation);
        messager.addEventListener(TopBarEvent.AFTER_UNDO, onAfterUndo);
        messager.addEventListener(TopBarEvent.AFTER_REDO, onAfterRedo);
    }

    public function setTabName(i:int, name:String){
        var tab:TabMc = container.getChildAt(i) as TabMc;
        tab.txt.text = name;
    }

    private function onMouseOver(e:MouseEvent):void{
        if(e.target.name.indexOf("tab")>=0 || (e.target.parent.name.indexOf("tab")>=0 && e.target.name=="txt") || e.target==tabBtn){
            Mouse.cursor = MouseCursor.BUTTON;
        }
    }

    private function onMouseOut(e:MouseEvent):void{
        if(e.target.name.indexOf("tab")>=0 || (e.target.parent.name.indexOf("tab")>=0 && e.target.name=="txt") || e.target==tabBtn){
            Mouse.cursor = MouseCursor.ARROW;
        }
    }

    private function onClick (e:MouseEvent):void{
        if(e.target.name.indexOf("tab")>=0 || (e.target.parent.name.indexOf("tab")>=0 && e.target.name=="txt")){
            trace("tab");
            for(var i:int=0;i<container.numChildren;i++){
                var tab:TabMc = container.getChildAt(i) as TabMc;
                tab.gotoAndStop("default");
            }
            var t:TabMc;
            if(e.target.name.indexOf("tab")>=0){
                t = e.target as TabMc;
            }else{
                t = e.target.parent as TabMc;
            }
            t.gotoAndStop("active");
            messager.dispatchEvent(new TopBarEvent(TopBarEvent.SELECT, t.tmpid));

            setTimeout(function () {
                checkUndoRedoBtn();
            }, 500);

        }else if(e.target==tabBtn){
            trace("tabBtn");
            var tmpid:int = TabMc(container.getChildAt(container.numChildren-1)).tmpid + 1;
            var tab:TabMc = new TabMc();
            tab.x = container.numChildren * tab.width;
            tab.y = Config.GAP;
            tab.tmpid = tmpid;
            tab.name = "tab"+tmpid;
            tab.txt.text = "设计"+tmpid;
            container.addChild(tab);
            tabBtn.x = container.x + container.width + Config.GAP;
            for(var i:int=0;i<container.numChildren;i++){
                var t:TabMc = container.getChildAt(i) as TabMc;
                t.btn.visible = true;
                t.txt.x = 25;
                t.gotoAndStop("default");
            }
            tab.gotoAndStop("active");
            tab.buttonMode = true;

            var obj = {
                id:0,
                tmpid:tab.tmpid,
                title:"",
                description:"",
                grids:[],
                gridSources:[],
                layers:[],
                layerSources:[],
                action:{
                    undoArr:[],
                    redoArr:[],
                    cache:{
                        grids:[],
                        layers:[]
                    }
                }
            };
            DataManager.layouts.push(obj);
            messager.dispatchEvent(new TopBarEvent(TopBarEvent.SELECT, tab.tmpid));
            checkUndoRedoBtn();

        }else if(e.target.parent.name.indexOf("tab")>=0 && e.target.name=="btn"){
            trace("del");
            currentTab = e.target.parent as TabMc;
            PopupManager.showConfirmDialog("是否删除此设计？");
        }else if(e.target==saveBtn){
            messager.dispatchEvent(new TopBarEvent(TopBarEvent.SAVE));
        }else if(e.target==submitBtn){
            messager.dispatchEvent(new TopBarEvent(TopBarEvent.SUBMIT));
        }else if(e.target==undoBtn || e.target.parent==undoBtn){
            var layout = DataManager.getLayout(DataManager.layoutTmpId);
            if(layout.action.undoArr.length>0){
                messager.dispatchEvent(new OperationEvent(OperationEvent.UNDO));
            }
        }else if(e.target==redoBtn || e.target.parent==redoBtn){
            var layout = DataManager.getLayout(DataManager.layoutTmpId);
            if(layout.action.redoArr.length>0){
                messager.dispatchEvent(new OperationEvent(OperationEvent.REDO));
            }
        }

        trace(e.target==undoBtn);
    }

    private function onAfterSaveOperation(e:TopBarEvent){
        checkUndoRedoBtn();
    }

    private function onAfterUndo(e:TopBarEvent){
        checkUndoRedoBtn();
    }

    private function onAfterRedo(e:TopBarEvent){
        checkUndoRedoBtn();
    }

    private function checkUndoRedoBtn(){

        var layout = DataManager.getLayout(DataManager.layoutTmpId);

        if(layout.action.undoArr.length>0){
            undoBtn.enabled = true;
            undoBtn.gotoAndStop('enabled');
        }else{
            undoBtn.enabled = false;
            undoBtn.gotoAndStop('disabled');
        }
        if(layout.action.redoArr.length>0){
            redoBtn.enabled = true;
            redoBtn.gotoAndStop('enabled');
        }else{
            redoBtn.enabled = false;
            redoBtn.gotoAndStop('disabled');
        }
    }

    private function onConfirm(e:TopBarEvent){
        delteLayout();
        PopupManager.hideConfirmDialog();
    }

    private function delteLayout(){
        var tmpid:int = currentTab.tmpid;
        var layout = DataManager.getLayout(tmpid);
        if(layout.id>0){
            ServiceManager.deleteLayout(layout.id);
        }
        DataManager.removeLayout(tmpid);
        trace('TopBar.container.numChildren', container.numChildren);
        var idx:int = container.getChildIndex(currentTab);
        trace('TopBar.container.click.idx', idx, container.contains(currentTab));
        //激活被删除前/后的TAB
        if(idx==container.numChildren-1){
            idx--;
        }
        container.removeChild(currentTab);
        for(var i:int=0;i<container.numChildren;i++){
            var tab:TabMc = container.getChildAt(i) as TabMc;
            tab.x = i*tab.width;
            if(container.numChildren==1){
                tab.btn.visible = false;
                tab.txt.x = 15;
            }
            trace(tab.name);
        }
        var t:TabMc = container.getChildAt(idx) as TabMc;
        t.gotoAndStop("active");
        messager.dispatchEvent(new TopBarEvent(TopBarEvent.SELECT, t.tmpid));

        tabBtn.x = container.x + container.width + Config.GAP;
    }

    private function onResize(e:Event):void{
        this.graphics.clear();
        this.graphics.lineStyle(1, Config.GRAY);
        this.graphics.beginFill(0xffffff);
        this.graphics.drawRect(0, 0, stage.stageWidth, 40);
        this.graphics.endFill();

        submitBtn.x = stage.stageWidth-submitBtn.width;
        saveBtn.x = submitBtn.x - saveBtn.width;
        redoBtn.x = saveBtn.x - redoBtn.width;
        undoBtn.x = redoBtn.x - undoBtn.width;
    }

}
}
