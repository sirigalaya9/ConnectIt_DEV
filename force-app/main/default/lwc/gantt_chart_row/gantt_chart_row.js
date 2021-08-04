import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

//import getProjects from "@salesforce/apex/ganttChart.getProjects";
//import saveAllocation from "@salesforce/apex/ganttChart.saveAllocation";
//import deleteAllocation from "@salesforce/apex/ganttChart.deleteAllocation";
import getProjects from "@salesforce/apex/newGanttChart.getProjects";
import getResources from "@salesforce/apex/newGanttChart.getResources";
import saveAllocation from "@salesforce/apex/newGanttChart.saveAllocation";
import saveTask from "@salesforce/apex/newGanttChart.saveTask";
import deleteAllocation from "@salesforce/apex/newGanttChart.deleteAllocation";

import fetchLookUpValues from "@salesforce/apex/newGanttChart.fetchLookUpValues";

import { getPicklistValues } from "lightning/uiObjectInfoApi";
import TASK_STATUS_FIELD from "@salesforce/schema/CCMI__Milestone_Task__c.CCMI__Status__c";
import getTeamResources from "@salesforce/apex/newGanttChart.getTeamResources";
// Import message service features
import {
  publish,
  subscribe,
  MessageContext,
  APPLICATION_SCOPE,
  releaseMessageContext,
  unsubscribe
} from "lightning/messageService";
import TASK_UPDATE_CHANNEL from "@salesforce/messageChannel/TaskUpdateChannel__c"; //
var resourceType; //WI-00500
export default class GanttChartRow extends NavigationMixin(LightningElement) {
  isLoading = false; // spinner

  @api rowType; // used to determine whether project view or resource view
  @api rowRecordId; // the Id of the Resource (in resource view) or Project (in project view) the row represents
  @api isResource; // used to determine whether the row represents a resource record
  @api isProject; // used to determine whether the row represents a resource record

  //@track ganttRowItems;

  //@api isResourceView; // resource page has different layout
  @api projectId; // used on project task page for quick adding of allocations
  @api projId; // Possibly to be used on project page...

  @api
  get rowData() {
    return this._rowData;
  }
  set rowData(_rowData) {
    this._rowData = _rowData;
    this.setProjects();
  }

  // dates
  @api startDate;
  @api endDate;
  @api dateIncrement;

  @api
  refreshDates(startDate, endDate, dateIncrement) {
    if (startDate && endDate && dateIncrement) {
      let times = [];
      /* let today = new Date();
      console.log('**today_date=='+today);
      today.setHours(0, 0, 0, 0);
      today = today.getTime();
      console.log('**today_time=='+today); */

      let today = moment().startOf("day");
      console.log("**today==" + today);

      for (
        let date = new Date(startDate);
        date <= endDate;
        date.setDate(date.getDate() + dateIncrement)
      ) {
        let time = {
          class: "slds-col lwc-timeslot",
          start: date.getTime()
        };

        if (dateIncrement > 1) {
          let end = new Date(date);
          end.setDate(end.getDate() + dateIncrement - 1);
          time.end = end.getTime();
        } else {
          time.end = date.getTime();

          if (times.length % 7 === 6) {
            time.class += " lwc-is-week-end";
            time.class += " lwc-is-disabled";
          } else if (times.length % 7 === 5) {
            time.class += " lwc-is-disabled";
          }
        }

        if (today >= time.start && today <= time.end) {
          time.class += " lwc-is-today";
        }

        times.push(time);
      }

      this.times = times;
      // console.log('times=='+JSON.stringify(this.times));
      this.startDate = startDate;
      this.endDate = endDate;
      this.dateIncrement = dateIncrement;
      this.setProjects();
    }
  }

  // used by parent level window
  @api
  closeAllocationMenu() {
    if (this.menuData.open) {
      this.menuData.show = true;
      this.menuData.open = false;
    } else {
      this.menuData = {
        show: false,
        open: false
      };
    }
  }

  // modal data
  @track addAllocationData = {};
  @track editAllocationData = {};
  // showEditTaskModal = false;

  @track menuData = {
    open: false,
    show: false,
    style: ""
  };

  @track projects = [];

  effortOptions = [
    {
      label: "Low",
      value: "Low"
    },
    {
      label: "Medium",
      value: "Medium"
    },
    {
      label: "High",
      value: "High"
    }
  ];

  @track statusOptions;

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: TASK_STATUS_FIELD
  })
  wiredStatusPickListValue({ data, error }) {
    if (data) {
      this.statusOptions = data.values;
    }
    if (error) {
      console.log(` Error while fetching Status Picklist values  ${error}`);
      this.statusOptions = [];
    }
  }

  @wire(fetchLookUpValues, {
    searchKey: "$searchValue",
    fieldName: "$fieldName",
    ObjectName: "$objectName",
    criteria: "$criteria",
    orderBy: "$orderBy"
  })
  picklistvalues({ data, error }) {
    if (data) {
      console.log("custom lookup data==" + JSON.stringify(data));
      // let picklistOptions = [{ key: '--None--', value: '--None--' }];
      let picklistOptions = [];
      data.forEach((key) => {
        picklistOptions.push({
          key: key.Id,
          value: key[this.fieldName]
        });
      });
      this.options = picklistOptions;
    } else if (error) {
      console.error(error);
    }
  }

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.refreshDates(this.startDate, this.endDate, this.dateIncrement);
  }

  // calculate allocation classes
  calcClass(allocation) {
    let classes = ["slds-is-absolute", "lwc-allocation"];
    console.log("Allocation status ==>> ", allocation.status);
    switch (allocation.status) {
      case "Unavailable":
        classes.push("unavailable");
        break;
      case "Hold":
        classes.push("hold");
        break;
      default:
        break;
    }

    if ("Unavailable" !== allocation.status) {
      switch (allocation.Effort__c) {
        case "Low":
          classes.push("low-effort");
          break;
        case "Medium":
          classes.push("medium-effort");
          break;
        case "High":
          classes.push("high-effort");
          break;
        default:
          break;
      }
    }
    console.log("classes.join ===>>>> ", classes);
    return classes.join(" ");
  }

  // calculate allocation positions/styles
  calcStyle(allocation) {
    if (!this.times) {
      return;
    }

    const totalSlots = this.times.length;
    let styles = [
      "left: " + (allocation.left / totalSlots) * 100 + "%",
      "right: " +
        ((totalSlots - (allocation.right + 1)) / totalSlots) * 100 +
        "%"
    ];

    // set background color - WI - 00803 - start
    var backgroundColor;
    const colorMap = {
      Amber: "#FFBF00",
      Blue: "#1589EE",
      Green: "#4AAD59",
      Red: "#E52D34",
      Turqoise: "#0DBCB9",
      Navy: "#052F5F",
      Orange: "#E56532",
      Purple: "#62548E",
      Pink: "#CA7CCE",
      Brown: "#823E17",
      Lime: "#7CCC47",
      Gold: "#FCAF32",
      Ecru: "#C2B280",
      Teal: "#008080",
      Turquoise: "#40E0D0"
    };
    if (!allocation.hasAssignments) {
      backgroundColor = "Blue";
    } else if (allocation.hasAssignments && !allocation.sentToBORIS) {
      backgroundColor = "Amber";
    } else if (allocation.hasAssignments && allocation.sentToBORIS) {
      backgroundColor = "Green";
    }
    styles.push("background-color: " + colorMap[backgroundColor]);
    // WI - 00803 - End

    if (!isNaN(this.dragInfo.startIndex)) {
      styles.push("pointer-events: none");
      styles.push("transition: left ease 250ms, right ease 250ms");
    } else {
      styles.push("pointer-events: auto");
      styles.push("transition: none");
    }

    return styles.join("; ");
  }

  // calculate allocation label position
  calcLabelStyle(allocation) {
    if (!this.times) {
      return;
    }

    const totalSlots = this.times.length;
    let left =
      allocation.left / totalSlots < 0 ? 0 : allocation.left / totalSlots;
    let right =
      (totalSlots - (allocation.right + 1)) / totalSlots < 0
        ? 0
        : (totalSlots - (allocation.right + 1)) / totalSlots;
    let styles = [
      "left: calc(" + left * 100 + "% + 15px)",
      "right: calc(" + right * 100 + "% + 30px)"
    ];

    if (!isNaN(this.dragInfo.startIndex)) {
      styles.push("transition: left ease 250ms, right ease 250ms");
    } else {
      styles.push("transition: none");
    }
    return styles.join("; ");
  }

  @api
  setProjects() {
    let self = this;
    self.projects = [];

    this.isResource = this.rowData.rowType === "resource" ? true : false;
    this.isProject = this.rowData.rowType === "project" ? true : false;

    // console.log('**self._resource==', JSON.stringify(self._resource));
    Object.keys(self._rowData.allocationsByProject).forEach((projectId) => {
      let project = {
        id: projectId,
        allocations: []
      };
      /*
      self.resource.allocationsByProject[projectId].forEach(allocation => {
        allocation.class = self.calcClass(allocation);
        allocation.style = self.calcStyle(allocation);
        allocation.labelStyle = self.calcLabelStyle(allocation);

        project.allocations.push(allocation);
      });
      */

      //fix for Uncaught (in promise) TypeError: 'set' on proxy: trap returned falsish for property 'class'
      self.rowData.allocationsByProject[projectId].forEach((allocation2) => {
        let allocation = JSON.parse(JSON.stringify(allocation2));
        allocation.class = self.calcClass(allocation);
        allocation.style = self.calcStyle(allocation);
        allocation.labelStyle = self.calcLabelStyle(allocation);
        let assignmentNames = [];
        Array.from(allocation.assignments).forEach((assign) => {
          assignmentNames.push(assign.ownerName);
        });
        allocation.assignmentString = allocation.hasAssignments
          ? assignmentNames.join(", ")
          : "No resources assigned";

        project.allocations.push(allocation);
      });

      self.projects.push(project);
    });
  }

  /* 
  handleAddAllocationDataChange(event) {
    this.addAllocationData[event.target.dataset.field] = event.target.value;

    if (!this.addAllocationData.projectId) {
      this.addAllocationData.disabled = true;
    } else {
      this.addAllocationData.disabled = false;
    }
  }

  addAllocationModalSuccess() {
    if ("Unavailable" === this.addAllocationData.projectId) {
      this.addAllocationData.projectId = null;
      this.addAllocationData.status = "Unavailable";
    }

    const startDate = moment(this.addAllocationData.startDate + "T00:00:00");
    const endDate = moment(this.addAllocationData.endDate + "T00:00:00");

    this._saveAllocation({
      projectId: this.addAllocationData.projectId,
      status: this.addAllocationData.status,
      // startDate: this.addAllocationData.startDate,
      // endDate: this.addAllocationData.endDate
      startDate: startDate + "",
      endDate: endDate + ""
    })
      .then(() => {
        this.addAllocationData = {};
        this.template.querySelector(".add-allocation-modal").hide();
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }
 */

  _saveAllocation(allocation) {
    /* if (
      null == allocation.projectId &&
      null != this.projectId &&
      !allocation.status
    ) {
      allocation.projectId = this.projectId;
    } */

    this.isLoading = true;

    // return saveAllocation(allocation)
    return saveTask(allocation)
      .then(() => {
        //send details to undo/redo component.
        const actionValue = allocation.taskId ? "update" : "new"; // if task id is missing then it is a new task. so reset the undo items.
        this.publishTaskModifiedMessage(allocation, actionValue); // if there is any change in date publish app event.
        this.isLoading = false;
        // send refresh to top
        this.dispatchEvent(
          new CustomEvent("refresh", {
            bubbles: true,
            composed: true
          })
        );
      })
      .catch((error) => {
        this.isLoading = false;
        this.dispatchEvent(
          new ShowToastEvent({
            message: error.body.message,
            variant: "error"
          })
        );
        console.log("apex error: " + error.body.message);
      });
  }

  /*** Drag/Drop ***/
  dragInfo = {};
  handleDragStart(event) {
    let container = this.template.querySelector(
      "." + event.currentTarget.dataset.id + " .lwc-allocation"
    );
    this.dragInfo.projectIndex = container.dataset.project;
    this.dragInfo.allocationIndex = container.dataset.allocation;
    this.dragInfo.newAllocation = this.projects[
      container.dataset.project
    ].allocations[container.dataset.allocation];

    // hide drag image
    container.style.opacity = 0;
    setTimeout(function () {
      container.style.pointerEvents = "none";
    }, 0);
  }

  handleLeftDragStart(event) {
    this.dragInfo.direction = "left";
    this.handleDragStart(event);
  }

  handleRightDragStart(event) {
    this.dragInfo.direction = "right";
    this.handleDragStart(event);
  }

  handleDragEnd(event) {
    event.preventDefault();

    const projectIndex = this.dragInfo.projectIndex;
    const allocationIndex = this.dragInfo.allocationIndex;
    const allocation = this.dragInfo.newAllocation;

    this.projects = JSON.parse(JSON.stringify(this.projects));
    this.projects[projectIndex].allocations[allocationIndex] = allocation;

    // let startDate = new Date(allocation.Start_Date__c + "T00:00:00Z");
    // let endDate = new Date(allocation.End_Date__c + "T00:00:00Z");
    let startDate = moment(allocation.startDate + "T00:00:00Z");
    let endDate = moment(allocation.endDate + "T00:00:00Z");

    console.log("allocation.startDate = " + allocation.startDate);
    console.log("allocation.endDate = " + allocation.endDate);
    console.log("startDate = " + startDate.toString());
    console.log("endDate = " + endDate.toString());
    console.log("startDate sent to server= ", startDate + "");
    console.log("endDate sent to server= ", endDate + "");

    this._saveAllocation({
      taskId: allocation.id,
      //startDate: startDate.getTime() + startDate.getTimezoneOffset() * 60 * 1000 + "",
      startDate: startDate + "",
      //endDate: endDate.getTime() + endDate.getTimezoneOffset() * 60 * 1000 + ""
      endDate: endDate + ""
    });

    this.dragInfo = {};
    this.template.querySelector(
      "." + allocation.id + " .lwc-allocation"
    ).style.pointerEvents = "auto";
  }

  handleDragEnter(event) {
    const projectIndex = this.dragInfo.projectIndex;
    const allocationIndex = this.dragInfo.allocationIndex;
    const direction = this.dragInfo.direction;
    const start = new Date(parseInt(event.currentTarget.dataset.start, 10));
    const end = new Date(parseInt(event.currentTarget.dataset.end, 10));
    const index = parseInt(event.currentTarget.dataset.index, 10);

    if (isNaN(this.dragInfo.startIndex)) {
      this.dragInfo.startIndex = index;
    }

    let allocation = JSON.parse(
      JSON.stringify(this.projects[projectIndex].allocations[allocationIndex])
    );

    switch (direction) {
      case "left":
        if (index <= allocation.right) {
          allocation.startDate = start.toJSON().substr(0, 10);
          allocation.left = index;
        } else {
          allocation = this.dragInfo.newAllocation;
        }
        break;
      case "right":
        if (index >= allocation.left) {
          allocation.endDate = end.toJSON().substr(0, 10);
          allocation.right = index;
        } else {
          allocation = this.dragInfo.newAllocation;
        }
        break;
      default:
        let deltaIndex = index - this.dragInfo.startIndex;
        let firstSlot = this.times[0];
        let startDate = new Date(firstSlot.start);
        let endDate = new Date(firstSlot.end);

        allocation.left = allocation.left + deltaIndex;
        allocation.right = allocation.right + deltaIndex;

        startDate.setDate(
          startDate.getDate() + allocation.left * this.dateIncrement
        );
        endDate.setDate(
          endDate.getDate() + allocation.right * this.dateIncrement
        );

        allocation.startDate = startDate.toJSON().substr(0, 10);
        allocation.endDate = endDate.toJSON().substr(0, 10);
    }

    this.dragInfo.newAllocation = allocation;
    this.template.querySelector(
      "." + allocation.id + " .lwc-allocation"
    ).style = this.calcStyle(allocation);
    this.template.querySelector(
      "." + allocation.id + " .lwc-allocation-label"
    ).style = this.calcLabelStyle(allocation);
  }
  /*** /Drag/Drop ***/

  handleTimeslotClick(event) {
    /* const start = new Date(parseInt(event.currentTarget.dataset.start, 10));
    const end = new Date(parseInt(event.currentTarget.dataset.end, 10));
    const startUTC = start.getTime() + start.getTimezoneOffset() * 60 * 1000;
    const endUTC = end.getTime() + end.getTimezoneOffset() * 60 * 1000; */
    const startUTC = moment(parseInt(event.currentTarget.dataset.start, 10));
    const endUTC = moment(parseInt(event.currentTarget.dataset.end, 10));
    console.log("startUTC==" + startUTC.toString());
    console.log("endUTC==" + endUTC.toString());

    console.log(" this.menuData.allocation.projectId ", this.rowData.id);
    console.log(
      `CCMI__Milestone_Project__c = '${
        this.rowType === "project" ? this.rowData.id.trim() : ""
      }'`
    );

    let _assignments = [];
    // if (this.rowData.id !== "unassigned") {
    if (this.rowType === "resource") {
      _assignments.push({
        ownerId: this.rowData.id,
        ownerName: "zz" + this.rowData.name
      });
    }

    this.editAllocationData = {
      startDate: startUTC.format("YYYY-MM-DD"),
      endDate: endUTC.format("YYYY-MM-DD"),
      startTime: "07:30",
      endTime: "16:30",
      disabled: true,
      isNew: true,
      status: "Not Started",
      borisJob: false,
      includeWeekends: false,
      parentTaskId: "",
      projectId: this.rowType === "project" ? this.rowData.id : "",
      projectIdCriteria: `CCMI__Milestone_Project__c = '${
        this.rowType === "project" ? this.rowData.id.trim() : ""
      }'`,
      hasAssignments: this.rowType === "resource" ? true : false,
      assignments: _assignments,
      assignmentsToRemove: [],
      parentTasks: []
    };

    /* if(this.projectId) {
      this._saveAllocation({
        startDate: startUTC + "",
        endDate: endUTC + ""
      });
    } else { */
    let self = this;

    getProjects()
      .then((projects) => {
        projects = projects.map((project) => {
          return {
            value: project.id,
            label: project.name
            //label: project.Display__c
          };
        });

        projects.unshift({
          value: "",
          label: "--None--"
        });

        self.editAllocationData.projects = projects;

        // self.showEditTaskModal = true;
        self.template.querySelector(".edit-allocation-modal").show();
        self.setEditTaskModalDisable();
      })
      .catch((error) => {
        console.log("apex error: " + JSON.stringify(error));
        this.dispatchEvent(
          new ShowToastEvent({
            message: error.body.message,
            variant: "error"
          })
        );
      });

    this._getResourceOptions();

    this.getParentTasks(this.rowData.id);
    // }
  }

  openAllocationMenu(event) {
    event.stopPropagation();
    let container = this.template.querySelector(
      "." + event.currentTarget.dataset.id + " .lwc-allocation"
    );
    let allocation = this.projects[container.dataset.project].allocations[
      container.dataset.allocation
    ];

    if (
      this.menuData.allocation &&
      this.menuData.allocation.id === allocation.id
    ) {
      this.closeAllocationMenu();
    } else {
      this.menuData.open = true;

      let projectHeight = this.template
        .querySelector(".project-container")
        .getBoundingClientRect().height;
      let allocationHeight = this.template
        .querySelector(".lwc-allocation")
        .getBoundingClientRect().height;
      let totalSlots = this.times.length;
      let rightEdge =
        ((totalSlots - (allocation.right + 1)) / totalSlots) * 100 + "%";

      let topEdge =
        projectHeight * container.dataset.project + allocationHeight;

      this.menuData.allocation = Object.assign({}, allocation);
      this.menuData.recordLink = "/" + allocation.id;

      this.menuData.style =
        "top: " + topEdge + "px; right: " + rightEdge + "; left: unset";
    }
  }

  // Convert milliseconds into 'hh:mm' time format
  msToTime(s) {
    if (!s) {
      return "";
    }
    let ms = s % 1000;
    s = (s - ms) / 1000;
    let secs = s % 60;
    s = (s - secs) / 60;
    let mins = s % 60;
    let hrs = (s - mins) / 60;
    hrs = hrs < 10 ? "0" + hrs : hrs;
    mins = mins < 10 ? "0" + mins : mins;
    console.log(hrs + ":" + mins);
    return hrs + ":" + mins;
    //return hrs+':' + mins + ':00.000Z';
  }

  handleModalEditClick(event) {
    console.log(
      " this.menuData.allocation.projectId ",
      this.menuData.allocation.projectId
    );
    console.log(
      "CCMI__Milestone_Project__c = '" +
        this.menuData.allocation.projectId +
        "'"
    );
    this.editAllocationData = {
      //resourceName: this.resource.name,
      //taskId: this.menuData.allocation.taskId,
      id: this.menuData.allocation.id,
      taskName: this.menuData.allocation.taskName,
      projectId: this.menuData.allocation.projectId,
      // projectIdCriteria: "CCMI__Milestone_Project__c = '"+this.menuData.allocation.projectId+"'",
      projectName: this.menuData.allocation.projectName,
      startDate: this.menuData.allocation.startDate,
      parentTaskId: this.menuData.allocation.parentTaskId,
      endDate: this.menuData.allocation.endDate,
      startTime: this.msToTime(this.menuData.allocation.startTime),
      endTime: this.msToTime(this.menuData.allocation.endTime),
      assignments: JSON.parse(
        JSON.stringify(this.menuData.allocation.assignments)
      ),
      hasAssignments: this.menuData.allocation.hasAssignments,
      assignmentsToRemove: [],
      status: this.menuData.allocation.status,
      area: this.menuData.allocation.area,
      borisJob: this.menuData.allocation.borisJob,
      includeWeekends: this.menuData.allocation.includeWeekends,
      isNew: false,
      disabled: false
    };

    // this.showEditTaskModal = true;
    this.template.querySelector(".edit-allocation-modal").show();
    this.setEditTaskModalDisable();
    this.closeAllocationMenu();

    console.log(
      "editAllocationData.assignments==",
      JSON.stringify(this.editAllocationData.assignments)
    );

    this._getResourceOptions();
    this.getParentTasks(this.editAllocationData.projectId);
  }

  _getResourceOptions() {
    console.log("inside _getResourceOptions");
    let self = this;
    let assignments = self.editAllocationData.assignments;
    console.log("assignments==" + JSON.stringify(assignments));

    getResources()
      .then((availableResources) => {
        console.log(
          "availableResources from apex==",
          JSON.stringify(availableResources)
        );

        let assignedResourceIds = assignments.map((assign) => {
          return assign.ownerId;
        });
        console.log(
          "assignedResourceIds==",
          JSON.stringify(assignedResourceIds)
        );
        self.editAllocationData.assignedResourceIds = assignedResourceIds;

        // availableResources = availableResources.filter(res => !assignedResourceIds.includes(res.id));
        // console.log('availableResources after filter==', JSON.stringify(availableResources));

        availableResources = availableResources.map((res) => {
          return {
            value: res.id,
            label: res.name
          };
        });

        availableResources.unshift({
          value: "",
          label: "-- Select Resource --"
        });

        console.log(
          "availableResources==" + JSON.stringify(availableResources)
        );
        self.editAllocationData.availableResources = availableResources;
        console.log(
          "self.editAllocationData.availableResources==" +
            JSON.stringify(self.editAllocationData.availableResources)
        );
      })
      .catch((error) => {
        console.log("error: ", error);
        self.dispatchEvent(
          new ShowToastEvent({
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }

  handleNewResourceSelection(event) {
    console.log("event==" + JSON.stringify(event));
    console.log("element clicked ==>> ", event.target.objectName);
    this.editAllocationData.newResourceId = event.detail.id;
    console.log(
      " this.editAllocationData.newResourceId >>>> ",
      this.editAllocationData.newResourceId
    );
    //resourceType = event.detail.name;
    resourceType = event.target.objectName;
    console.log("resource type ==> ", resourceType);
  }

  handleNewResourceRemoval(event) {
    console.log("event==" + JSON.stringify(event));
    this.editAllocationData.newResourceId = "";
  }

  handleAddAssignment(event) {
    let newResourceId = this.editAllocationData.newResourceId;
    // let newResourceId = event.detail.selectedRecordId;
    console.log("newResourceId==", JSON.stringify(newResourceId));

    if (newResourceId) {
      if (this.editAllocationData.assignedResourceIds.includes(newResourceId)) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: "The selected resource is already assigned to the task",
            variant: "error"
          })
        );
        return;
      }

      console.log(
        "this.editAllocationData.availableResources==",
        JSON.stringify(this.editAllocationData.availableResources)
      );

      console.log(
        "resource type before retrieving team records ==> ",
        resourceType
      );
      //if (resourceType.includes("TM-", 0)) {
      if (resourceType === "Team__c") {
        var tempNewResourceId = newResourceId;
        console.log("Team Name spotted - Team Name Id - ", newResourceId);
        getTeamResources({ teamId: newResourceId })
          .then((result) => {
            console.log(
              "R3 - Result from Apex ==>>>> ",
              JSON.stringify(result)
            );
            var teamArray = result;
            console.log("R3 - Array of team members ==>> ", teamArray);
            console.log("R3 - Reading Team Members");
            for (var i = 0; i < teamArray.length; i++) {
              console.log("R3 - List of Users ", teamArray[i]);
              if (teamArray[i] != null) {
                newResourceId = teamArray[i];
                console.log(
                  "R3 - Team member being assigned >>>>> ",
                  newResourceId
                );
                this.allocateResource(newResourceId);

                this.editAllocationData.hasAssignments =
                  this.editAllocationData.assignments.length > 0 ? true : false;
              }
            }
            //  // newResourceId = tempNewResourceId;
            //  // console.log("new resource id is team Id ", newResourceId);
            //  // this.editAllocationData.newResourceId = tempNewResourceId;
            //   console.log(
            //     "new this.editAllocationData.newResourceId >>>>>  ",
            //     this.editAllocationData.newResourceId
            //   );
            //  // this.editAllocationData.newResourceId = "";
            //   this.template.querySelector("c-custom-lookup").removeSelection();
          })

          .catch((error) => {
            console.log("Error from Apex ==>> ", error);
          });
      } else {
        console.log("Team Member spotted - Team Member Id - ", newResourceId);
        this.allocateResource(newResourceId);

        this.editAllocationData.hasAssignments =
          this.editAllocationData.assignments.length > 0 ? true : false;
        this.editAllocationData.newResourceId = "";
        this.template.querySelector("c-custom-lookup").removeSelection();
      }
    }
  }

  /****** WI-0500 - Method added to integrate the existing logic for allocating resource - Start*****/
  allocateResource(newResourceId) {
    var assignedResourcesArray = JSON.stringify(
      this.editAllocationData.assignedResourceIds
    );
    console.log(
      "allocateResource: new Resource Id being passed ==>>> ",
      newResourceId
    );
    console.log(
      "Available Resources data ===>>> ",
      JSON.stringify(this.editAllocationData.availableResources)
    );
    if (assignedResourcesArray.includes(newResourceId) === false) {
      console.log("Assigning the team member");

      let selectedResource = this.editAllocationData.availableResources.filter(
        (item) => item.value === newResourceId
      )[0];
      console.log("selectedResource ==>>>> ", JSON.stringify(selectedResource));

      if (selectedResource != null) {
        this.editAllocationData.assignments.push({
          ownerId: newResourceId,
          // ownerName: availableResourcesMap[newResourceId]
          ownerName: selectedResource.label
        });
        console.log(
          "this.editAllocationData.assignments==",
          JSON.stringify(this.editAllocationData.assignments)
        );
        this.editAllocationData.assignedResourceIds.push(newResourceId);
        console.log(
          "this.editAllocationData.assignedResourceIds ===>>> ",
          JSON.stringify(this.editAllocationData.assignedResourceIds)
        );
      }
    }
  }
  /****** WI-0500 - Method added to integrate the existing logic for for allocating resource - End*****/

  handleRemoveAssignment(event) {
    let resourceIdToRemove = event.currentTarget.dataset.id;
    console.log("resourceIdToRemove==" + resourceIdToRemove);

    let assignmentToRemove = this.editAllocationData.assignments.filter(
      (item) => item.ownerId == resourceIdToRemove
    )[0];
    console.log("assignmentToRemove==", JSON.stringify(assignmentToRemove));
    this.editAllocationData.assignmentsToRemove.push(assignmentToRemove);
    console.log(
      "this.editAllocationData.assignmentsToRemove==",
      JSON.stringify(this.editAllocationData.assignmentsToRemove)
    );

    console.log(
      "this.editAllocationData.assignments==",
      JSON.stringify(this.editAllocationData.assignments)
    );
    this.editAllocationData.assignments = this.editAllocationData.assignments.filter(
      (item) => item.ownerId !== resourceIdToRemove
    );
    console.log(
      "this.editAllocationData.assignments==",
      JSON.stringify(this.editAllocationData.assignments)
    );
    this.editAllocationData.assignedResourceIds = this.editAllocationData.assignedResourceIds.filter(
      (item) => item !== resourceIdToRemove
    );
    console.log(
      "this.editAllocationData.assignedResourceIds==",
      JSON.stringify(this.editAllocationData.assignedResourceIds)
    );

    this.editAllocationData.hasAssignments = this.editAllocationData.assignments
      .length
      ? true
      : false;
    // this.editAllocationData.availableResources.push();
  }

  handleEditAllocationDataChange(event) {
    this.editAllocationData[event.target.dataset.field] = event.target.value;
    console.log(" event.target.value ", event.target.value);
    if (event.target.dataset.field == "projectId") {
      this.getParentTasks(event.target.value);
    }
    this.setEditTaskModalDisable();
  }

  setEditTaskModalDisable() {
    // if (!this.editAllocationData.startDate ||
    //     !this.editAllocationData.endDate ||
    //     !this.editAllocationData.startTime ||
    //     !this.editAllocationData.endTime ||
    //     !this.editAllocationData.status ||
    //     !this.editAllocationData.taskName ||
    //     !this.editAllocationData.projectId )
    // {
    //   this.editAllocationData.disabled = true;
    // } else {
    //   this.editAllocationData.disabled = false;
    // }

    if (
      !this.editAllocationData.startDate ||
      !this.editAllocationData.endDate ||
      (this.editAllocationData.isNew && !this.editAllocationData.startTime) ||
      (this.editAllocationData.isNew && !this.editAllocationData.endTime) ||
      !this.editAllocationData.status ||
      !this.editAllocationData.taskName ||
      !this.editAllocationData.projectId
    ) {
      this.editAllocationData.disabled = true;
    } else {
      this.editAllocationData.disabled = false;
    }
  }

  editAllocationModalSuccess() {
    //const startDate = new Date(this.editAllocationData.startDate + "T00:00:00");
    //const endDate = new Date(this.editAllocationData.endDate + "T00:00:00");
    const startDate = moment(this.editAllocationData.startDate + "T00:00:00");
    const endDate = moment(this.editAllocationData.endDate + "T00:00:00");

    console.log(
      "editAllocationData.startTime==",
      JSON.stringify(this.editAllocationData.startTime)
    );
    console.log(
      "editAllocationData.endTime==",
      JSON.stringify(this.editAllocationData.endTime)
    );

    this._saveAllocation({
      taskId: this.editAllocationData.id,
      taskName: this.editAllocationData.taskName,
      projectId: this.editAllocationData.projectId,
      //startDate: startDate.getTime() + startDate.getTimezoneOffset() * 60 * 1000 + "",
      //endDate: endDate.getTime() + startDate.getTimezoneOffset() * 60 * 1000 + "",
      startDate: startDate + "",
      endDate: endDate + "",
      startTime: this.editAllocationData.startTime + "",
      endTime: this.editAllocationData.endTime + "",
      parentTaskId: this.editAllocationData.parentTaskId
        ? this.editAllocationData.parentTaskId
        : null,
      // parentTask: "a0u4J0000004Q1yQAE",
      status: this.editAllocationData.status,
      area: this.editAllocationData.area,
      borisJob: this.editAllocationData.borisJob,
      includeWeekends: this.editAllocationData.includeWeekends,
      assignmentsToSave: JSON.stringify(this.editAllocationData.assignments),
      assignmentsToRemove: JSON.stringify(
        this.editAllocationData.assignmentsToRemove
      )
    })
      .then(() => {
        this.editAllocationData = {};
        this.template.querySelector(".edit-allocation-modal").hide();
        // this.showEditTaskModal = false;
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }

  /* closeEditTaskModal() {
    this.template.querySelector(".edit-allocation-modal").hide();
    // this.showEditTaskModal = false;
  } */

  handleMenuDeleteClick(event) {
    this.editAllocationData = {
      id: this.menuData.allocation.id
    };
    this.template.querySelector(".delete-modal").show();
    this.closeAllocationMenu();
  }

  handleMenuDeleteSuccess() {
    this.publishTaskModifiedMessage(this.editAllocationData, "delete");
    deleteAllocation({
      allocationId: this.editAllocationData.id
    })
      .then(() => {
        this.template.querySelector(".delete-modal").hide();
        this.dispatchEvent(
          new CustomEvent("refresh", {
            bubbles: true,
            composed: true
          })
        );
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            message: error.body.message,
            variant: "error"
          })
        );
        console.log("apex error: " + error.body.message);
      });
  }

  setParentTask(event) {
    console.log("event==" + JSON.stringify(event));
    this.editAllocationData.parentTaskId = {
      id: event.detail.id,
      name: event.detail.name
    };
  }
  removeParentTask(event) {
    console.log("event==" + JSON.stringify(event));
    this.editAllocationData.parentTaskId = { id: "", name: "" };
  }
  parentTaskChangeHandler(event) {
    //console.log('setParentTask2 - event=='+JSON.stringify(event));
    this.editAllocationData.parentTaskId = event.detail.value;
  }
  getParentTasks(projectId) {
    console.log(
      " refresh parent tasks when Parent ID changes and reset the seleted Parent Task ID to empty"
    );

    //public static List<sObject> fetchLookUpValues(String searchKey, String fieldName, String ObjectName, String criteria, String orderBy) {
    var searchValue = null;
    var fieldName = "name";
    var objectName = "CCMI__Milestone_Task__c";
    var criteria = `CCMI__Milestone_Project__c = '${projectId}'`;
    var orderBy = "name";

    let self = this;
    if (projectId === "unassigned") {
      return;
    }

    if (projectId) {
      fetchLookUpValues({
        searchKey: searchValue,
        fieldName: fieldName,
        ObjectName: objectName,
        criteria: criteria,
        orderBy: orderBy
      })
        .then((parentTasks) => {
          console.log(" returned from fetch lookup ", parentTasks);

          parentTasks = parentTasks.map((task) => {
            return {
              key: task.Id,
              label: task.Name,
              value: task.Id
            };
          });

          parentTasks.unshift({
            key: "-1",
            label: "--None--",
            value: "--None--"
          });

          self.editAllocationData.parentTasks = [...parentTasks];
          console.log(
            "self.editAllocationData.parentTasks ",
            self.editAllocationData.parentTasks
          );
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              message: error.body.message,
              variant: "error"
            })
          );
          console.log("apex error: " + error);
        });
    } else {
      self.editAllocationData.parentTasks = [];
    }
  }

  publishTaskModifiedMessage(allocation, action) {
    console.log(" action -> ", action);
    let message = {};
    let currentTask;
    let currentProjectId = "";
    let currentResourceId = "";

    const rowData = this._rowData;
    const rowType = rowData.rowType
      ? rowData.rowType
      : !rowData.isResource
      ? "unassigned"
      : "unknown";

    switch (action) {
      case "update":
        if (rowType === "resource") {
          currentResourceId = rowData.id;
          let currResProjects = Object.keys(this._rowData.allocationsByProject);
          console.log("currResProjects ->", currResProjects);
          currResProjects.forEach((projId) => {
            if (!currentTask) {
              currentTask = this._rowData.allocationsByProject[projId].find(
                (task) => task.id == allocation.taskId
              );
            }
            //if(currentTask) {break;} // if task found then break the loop, dont continue further.
          });
        } else if (rowType === "project") {
          currentProjectId = rowData.id;
          currentTask = rowData.allocationsByProject[currentProjectId].find(
            (task) => task.id == allocation.taskId
          );
        } else if (rowType === "unassigned") {
          if (this._rowData.tasks) {
            currentTask = this._rowData.tasks.find(
              (x) => x.id === allocation.taskId
            );
          }
        }

        console.log(" matching task  -> ", currentTask);
        let oldStartDate = moment(currentTask.startDate + "T00:00:00Z") + "";
        let oldEndDate = moment(currentTask.endDate + "T00:00:00Z") + "";
        let redos = [];
        let popupRedo = "";
        if (currentTask.popup) {
          redos = currentTask.popup.split(",");
          popupRedo =
            redos[0] +
            ", " +
            redos[1] +
            ", Start:" +
            moment(new Date(parseInt(allocation.startDate))).format(
              "YYYY-DD-MM"
            ) +
            ", End:" +
            moment(new Date(parseInt(allocation.endDate))).format(
              "YYYY-DD-MM"
            ) +
            " ";
        }

        message = {
          action: "update",
          projectId: currentTask.projectId,
          resourceId: currentResourceId,
          taskId: currentTask.id,
          popupUndo: currentTask.popup ? currentTask.popup : "",
          popupRedo: popupRedo,
          dateData: {
            newStartDate: allocation.startDate,
            newStartTime: allocation.startTime,
            newEndDate: allocation.endDate,
            newEndTime: allocation.endTime,

            oldStartDateStr: currentTask.startDate,
            oldEndDateStr: currentTask.endDate,
            newStartDateStr: new Date(
              parseInt(allocation.startDate)
            ).toUTCString(),
            newEndDateStr: new Date(parseInt(allocation.endDate)).toUTCString(),

            oldStartDate: oldStartDate,
            oldStartTime: currentTask.startTime,
            oldEndDate: oldEndDate,
            oldEndTime: currentTask.endTime
          }
        };

        publish(this.messageContext, TASK_UPDATE_CHANNEL, message);
        break;
      case "new":
        message = {
          action: "new"
        };
        publish(this.messageContext, TASK_UPDATE_CHANNEL, message);
        break;
      case "delete":
        message = {
          action: "delete",
          taskId: allocation.id
        };

        publish(this.messageContext, TASK_UPDATE_CHANNEL, message);
      default:
        break;
    }
  }

  handleTaskEditClick(event) {
    let taskIdToEdit = event.currentTarget.dataset.id;
    console.log("taskIdToEdit :", taskIdToEdit);
    let container = this.template.querySelector(
      "." + event.currentTarget.dataset.id + " .lwc-allocation"
    );
    console.log("container :", container);

    let allocation = this.projects[container.dataset.project].allocations[
      container.dataset.allocation
    ];
    console.log("allocation :", allocation);

    this.menuData.allocation = Object.assign({}, allocation);
    this.menuData.recordLink = "/" + allocation.id;

    this.handleModalEditClick(event);
  }

  deleteAllocationClickHanlder(event) {
    this.template.querySelector(".edit-allocation-modal").hide();
    this.template.querySelector(".delete-modal").show();
  }

  navigateToRecordClickHandler(event) {
    event.preventDefault();
    event.stopPropagation();
    let id = event.currentTarget.dataset.id;

    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      type: "standard__recordPage",
      attributes: {
        recordId: id,
        objectApiName: "CCMI__Milestone_Task__c",
        actionName: "view"
      }
    }).then((generatedUrl) => {
      window.open(generatedUrl);
    });
  }

  navigateToProjectHandler(event) {
    //console.log("navigateToProjectHandler: event==" + JSON.stringify(event));
    //console.log("navigateToProjectHandler: element clicked ==>> ", event.target.objectName);
    event.preventDefault();
    event.stopPropagation();
    let id = event.target.dataset.id;
    //let id = 'a0s4J0000027nlrQAA';
    console.log("navigateToProjectHandler id ==>> ", id);
    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      attributes: {
        recordId: event.target.dataset.id,
        objectApiName: "CCMI__Milestone_Project__c",
        actionName: "view"
      }
    }).then((generatedUrl) => {
      window.open(generatedUrl);
    });
  }
}