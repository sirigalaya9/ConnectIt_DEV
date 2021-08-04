// LWC 
import { LightningElement, wire, track, api} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// Import message service features
import { publish,subscribe, MessageContext,APPLICATION_SCOPE, releaseMessageContext,unsubscribe } from 'lightning/messageService';
import TASK_UPDATE_CHANNEL from '@salesforce/messageChannel/TaskUpdateChannel__c'; // Todo: not ready yet
import REFRESH_GANTT_CHART_CHANNEL from '@salesforce/messageChannel/RefreshGanttChartChannel__c'; // Todo: not ready yet
import SHOW_SPINNER_CHANNEL from '@salesforce/messageChannel/ShowSpinnerChannel__c'; // To show/hide main spinner 

// task calls 
import saveTask from "@salesforce/apex/newGanttChart.saveTask";


export default class GanttUndo extends LightningElement {
    @wire(MessageContext)
    messageContext;
    
    undoHistory = new Array(); 
    redoHistory = new Array();
    @track disableUndoBtn =false; // Todo : conditionally set the enable/disable undo btn .
    @track disableRedoBtn =false;

    subscription = null; // Taskupdate Message Channel Subscription 

    isLoading = false; // spinner

    @track undoToolText = "Undo last date change";
    @track redToolText = "Redo last date change";

    connectedCallback() {
        this.subscribeMC();
        this.toggleBtns();
        //LMS_Service.
    }
    
    disconnectCallback() {
        unregisterAllListeners(this);
    }

    subscribeMC() {
        // LMS_Service.subscribeMC(this.subscription, this.taskUpdateHandler);
        // messageService.subscribeMC(this.subscription, this.taskUpdateHandler);
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            this.messageContext,
            TASK_UPDATE_CHANNEL,
            (message) => this.taskUpdateHandler(message),
            { scope: APPLICATION_SCOPE }
        );
    }

    redoTaskDateChange(){
        console.log(' Redo Last task date change');
        // this.changeHistory.push();
        if( this.redoHistory  && Array.isArray(this.redoHistory) && this.redoHistory.length > 0)
        {
            var redoTask = this.redoHistory.pop();
            this.undoHistory.push(redoTask);
            this._saveAllocation({
                taskId: redoTask.taskId,
                startDate: redoTask.dateData.newStartDate + "",
                endDate: redoTask.dateData.newEndDate + ""
              });
        }
        else{
            console.log('No items to redo');
        }
        this.toggleBtns();
    }
    undoTaskDateChange(){
        console.log(' Undo Last task date change');
        // this.changeHistory.push();
        if( this.undoHistory  && Array.isArray(this.undoHistory) && this.undoHistory.length > 0)
        {
            var untask = this.undoHistory.pop();
            this.redoHistory.push(untask);
            this._saveAllocation({
                taskId: untask.taskId,
                startDate: untask.dateData.oldStartDate + "",
                endDate: untask.dateData.oldEndDate + ""
              });
        }
        else{
            console.log('No items to undo');
        }
        this.toggleBtns();
    }

    toggleBtns(){
        this.disableUndoBtn = this.undoHistory.length <= 0; // if no history then disable the undo button.
        if(!this.disableUndoBtn){
            let nextUndoItem = this.undoHistory[this.undoHistory.length - 1];
            this.undoToolText = nextUndoItem.popupUndo? nextUndoItem.popupUndo : 'undo last action';
        }

        this.redoToolText = 'redo last action';
        this.disableRedoBtn = this.redoHistory.length <= 0; // if no history then disable the undo button.
        if(!this.disableRedoBtn){
            let nextRedoItem = this.redoHistory[this.redoHistory.length - 1];

            this.redoToolText = nextRedoItem.popupRedo? nextRedoItem.popupRedo : 'undo last action';

            // if (nextRedoItem.popupRedo) {
            //     let redos = nextRedoItem.popupRedo.split(",");
            //     this.redoToolText = redos[0] + ', '  + redos[1] + ', ' + nextRedoItem.dateData.oldStartDate + ', ' + nextRedoItem.dateData.oldEndDate;
            // }
        }
    }

    taskUpdateHandler(message){
        console.log(' TaskDateTimeChange Event Handler  ' , message);
        if(message.action === 'delete')
        {
            // remove all items for taskid from undoHistory and redoHistory
            if(this.redoHistory && this.redoHistory.length > 0){
                this.redoHistory = this.redoHistory.filter(item => !(item.taskId === message.taskId));
            }
            if(this.undoHistory && this.undoHistory.length > 0){
                this.undoHistory = this.undoHistory.filter(item => !(item.taskId === message.taskId));
            }
        }
        if(message.action === 'update'){
            this.undoHistory.push(message);
        }
        this.toggleBtns();
    }

    _saveAllocation(allocation ) {
        publish(this.messageContext, SHOW_SPINNER_CHANNEL, {isLoading:true});
        return saveTask(allocation)
          .then(() => {
            publish(this.messageContext, SHOW_SPINNER_CHANNEL, {isLoading:false});
            publish(this.messageContext, REFRESH_GANTT_CHART_CHANNEL, {});
          })
          .catch(error => {
            publish(this.messageContext, SHOW_SPINNER_CHANNEL, {isLoading:false});
            this.dispatchEvent(
              new ShowToastEvent({
                message: error.body.message,
                variant: "error"
              })
            );
            console.log("apex error: " + error.body.message);
          });
      }
}