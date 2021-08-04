import {LightningElement,wire } from 'lwc';

// Import message service features
import { publish,subscribe, MessageContext,APPLICATION_SCOPE, releaseMessageContext,unsubscribe } from 'lightning/messageService';
import TASK_UPDATE_CHANNEL from '@salesforce/messageChannel/TaskUpdateChannel__c'; // Todo: not ready yet


export default class LmsMessageService  extends LightningElement {

    @wire(MessageContext)
    messageContext;

    subscription = null;

    publishTaskModifiedMessage(taskId) {
        console.log('  JSON.parse(JSON.stringify(this.projects)); ', JSON.parse(JSON.stringify(this.rowData)));
        const rowDataNew = JSON.parse(JSON.stringify(this._rowData));
        const projectId = rowDataNew.id;
        const currentTask = rowDataNew.allocationsByProject[projectId].find(task => task.id == allocation.taskId);


        // const currentTask = "";
        const message = {
            recordId: currentTask.taskId,
            message: "This is simple message from LWC" + JSON.stringify(currentTask),
            source: "LWC",
            recordData: {
                // oldStartTime  : currentTask.startTime,
                // oldStartDate  : currentTask.startDate,
                // oldEndDate    : currentTask.endDate,
                // oldEndTime    : currentTask.endTime,

                // newStartTime  : allocation.startTime ??  '',
                // newStartDate  : allocation.startDate ??  '',
                // newEndDate    : allocation.endDate ?? '',
                // newEndTime    : allocation.endTime ?? ''
            }
        };
        publish(this.messageContext, TASK_UPDATE_CHANNEL, message);
    }

    subscribeMC( subscription, handler ) {
        if (subscription) {
            return;
        }
        subscription = subscribe(
            this.messageContext,
            TASK_UPDATE_CHANNEL,
            (message) => handler(message),
            { scope: APPLICATION_SCOPE }
        );
    }

}