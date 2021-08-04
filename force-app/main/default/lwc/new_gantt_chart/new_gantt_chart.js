/**
 * @description       :
 * @author            : Jonny Harte
 * @group             :
 * @last modified on  : 20-02-2021
 * @last modified by  : Jonny Harte
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   20-02-2021   Jonny Harte   Initial Version
 **/
import { LightningElement, api, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import momentJS from "@salesforce/resourceUrl/momentJS";
import momentJS_tz from "@salesforce/resourceUrl/momentJS_tz";
import { loadScript } from "lightning/platformResourceLoader";

//import getChartData from "@salesforce/apex/newGanttChart.getChartData";
import getGanttChartSettings from "@salesforce/apex/newGanttChart.getGanttChartSettings";
import setGanttChartSettings from "@salesforce/apex/newGanttChart.setGanttChartSettings";
import getProjects from "@salesforce/apex/newGanttChart.getProjects";
import getAccounts from "@salesforce/apex/newGanttChart.getAccounts";
import getResources from "@salesforce/apex/newGanttChart.getResources";
import getRoles from "@salesforce/apex/newGanttChart.getRoles";
import getStatus from "@salesforce/apex/newGanttChart.getStatus";
import getType from "@salesforce/apex/newGanttChart.getType";
import getArea from "@salesforce/apex/newGanttChart.getArea";
import getProjManager from "@salesforce/apex/newGanttChart.getProjManager";
import getGanttChartData from "@salesforce/apex/newGanttChart.getGanttChartData";

// import { getPicklistValues } from "lightning/uiObjectInfoApi";
// import TASK_STATUS_FIELD from "@salesforce/schema/CCMI__Milestone_Task__c.CCMI__Status__c";
// import PROJECT_STATUS_FIELD from "@salesforce/schema/CCMI__Milestone_Project__c.CCMI__Status_Override__c";
// import PROJECT_TYPE_FIELD from "@salesforce/schema/CCMI__Milestone_Project__c.CCMI__Type__c";
// import PROJECT_AREA_FIELD from "@salesforce/schema/CCMI__Milestone_Task__c.Project_Area__c";

// Import message service features
import {
  publish,
  subscribe,
  MessageContext,
  APPLICATION_SCOPE,
  releaseMessageContext,
  unsubscribe
} from "lightning/messageService";
import REFRESH_GANTT_CHART_CHANNEL from "@salesforce/messageChannel/RefreshGanttChartChannel__c"; // To refresh main component.
import SHOW_SPINNER_CHANNEL from "@salesforce/messageChannel/ShowSpinnerChannel__c"; // To show/hide main spinner

export default class GanttChart extends LightningElement {
  TIME_ZONE = "Etc/UTC"; // To set the default timezone to UTC (GMT)
  DEFAULT_GANTT_VIEW = "resource-overview"; // To set the default view of the gantt chart if the 'defaultView' property is not set from the lightning page
  DEFAULT_ROWS_PER_PAGE = 10; // The default number of Project/Resource records per page

  @api recordId;
  @api objectApiName;

  isLoading = true;

  currentView;
  isResourceOverview;
  //isRoleOverview;
  isProjectOverview;
  isResourceRecordView;
  isProjectRecordView;

  @api showOnlyUnAllocatedResource = false;

  //isResourceView;

  // design attributes
  @api defaultView;
  @api defaultTimelineView;

  // navigation
  startDateUTC; // sending to backend using time string
  endDateUTC; // sending to backend using time string
  formattedStartDate; // Title (Date Range)
  formattedEndDate; // Title (Date Range)
  @track dates = []; // Dates (Header)
  dateShift = 7; // determines how many days shift by when clicking the next and previous buttons

  // options
  datePickerString; // Date Navigation
  @track view = {
    // View Select
    options: [
      //{
      //  label: "View 2 weeks",
      //  value: "1/14"
      //},
      //{
      //label: "View by Week",
      //value: "7/10"
      //},
      {
        label: "View 4 weeks",
        value: "1/28"
      }
    ],
    slotSize: 1,
    slots: 1
  };

  // @wire(getPicklistValues, {
  //   recordTypeId: "012000000000000AAA",
  //   fieldApiName: PROJECT_STATUS_FIELD,
  // })
  // wiredStatusPickListValue({ data, error }) {
  //   if (data) {
  //     this.filterModalData.statusOptions = this.filterModalData.statusOptions.concat(
  //       data.values
  //     );
  //     console.log(
  //       "this.filterModalData.statusOptions==" +
  //         JSON.stringify(this.filterModalData.statusOptions)
  //     );
  //   }
  //   if (error) {
  //     console.error(
  //       "Error while fetching Project Status Picklist values: " +
  //         JSON.stringify(error)
  //     );
  //   }
  // }

  // @wire(getPicklistValues, {
  //   recordTypeId: "012000000000000AAA",
  //   fieldApiName: PROJECT_TYPE_FIELD
  // })
  // wiredTypePickListValue({ data, error }) {
  //   if (data) {
  //     this.filterModalData.typeOptions = this.filterModalData.typeOptions.concat(
  //       data.values
  //     );
  //     console.log(
  //       "this.filterModalData.typeOptions==" +
  //         JSON.stringify(this.filterModalData.typeOptions)
  //     );
  //   }
  //   if (error) {
  //     console.error(
  //       "Error while fetching Project Type Picklist values: " +
  //         JSON.stringify(error)
  //     );
  //   }
  // }

  // @wire(getPicklistValues, {
  //   recordTypeId: "012000000000000AAA",
  //   fieldApiName: PROJECT_AREA_FIELD
  // })
  // wiredAreaPickListValue({ data, error }) {
  //   if (data) {
  //     this.filterModalData.areaOptions = this.filterModalData.areaOptions.concat(
  //       data.values
  //     );
  //     console.log(
  //       "this.filterModalData.areaOptions==" +
  //         JSON.stringify(this.filterModalData.areaOptions)
  //     );
  //   }
  //   if (error) {
  //     console.error(
  //       "Error while fetching Project Area Picklist values: " +
  //         JSON.stringify(error)
  //     );
  //   }
  // }

  /*** Modals ***/
  // TODO: move filter search to new component
  @track filterModalData = {
    disabled: true,
    message: "",
    projects: [],
    accounts: [],
    resources: [],
    roles: [],
    status: [],
    type: [],
    area: [],
    projManager: [],
    account: { id: "", name: "" }, //NOTE: why account and accounts?
    projectOptions: [],
    accountOptions: [],
    resourceOptions: [],
    roleOptions: [],
    statusOptions: [],
    typeOptions: [],
    areaOptions: [],
    projManagerOptions: []
  };

  _filterData = {
    projects: [],
    projectIds: [],
    resources: [],
    resourceIds: [],
    roles: [],
    roleIds: [],
    status: [],
    statusIds: [],
    type: [],
    typeIds: [],
    area: [],
    areaIds: [],
    projManager: [],
    projManagerIds: [],
    account: { id: "", name: "" }
  };

  @track resourceModalData = {};
  /*** /Modals ***/

  // gantt_chart_row
  startDate;
  endDate;
  //projectId;
  @track ganttRows = [];

  constructor() {
    super();
    this.template.addEventListener("click", this.closeDropdowns.bind(this));
  }

  connectedCallback() {
    Promise.all([
      loadScript(this, momentJS),
      loadScript(this, momentJS_tz)
    ]).then(() => {
      this.setGanttView();
      switch (this.defaultTimelineView) {
        case "View 2 weeks":
          this.setTimelineView("1/14");
          break;
        case "View 4 weeks":
          this.setTimelineView("1/28");
          break;
        default:
          //this.setTimelineView("1/14");
          this.setTimelineView("1/28");
      }

      console.log("TIME_ZONE==" + this.TIME_ZONE);
      moment.tz.setDefault(this.TIME_ZONE);
      moment.locale("en_GB");

      console.log("moment() after setting tz==" + moment().toString());

      //this.setStartDate(new Date());
      this.setStartDate(moment());

      getGanttChartSettings()
        .then((data) => {
          console.log("custom settings data==" + JSON.stringify(data));
          this._filterData = {
            projects: data.filterProjects
              ? JSON.parse(data.filterProjects)
              : [],
            resources: data.filterProjects
              ? JSON.parse(data.filterResources)
              : [],
            roles: data.filterRoles ? JSON.parse(data.filterRoles) : [],
            accounts: data.filterAccounts
              ? JSON.parse(data.filterAccounts)
              : [],
            status: data.filterStatus ? JSON.parse(data.filterStatus) : [],
            type: data.filterType ? JSON.parse(data.filterType) : [],
            area: data.filterArea ? JSON.parse(data.filterArea) : [],
            projManager: data.filterProjManager
              ? JSON.parse(data.filterProjManager)
              : []
            /*,
            account: data.filterAccounts
              ? JSON.parse(data.filterAccounts)
              : { id: "", name: "" } */
          };

          this._filterData.projectIds = this._filterData.projects.map(
            (project) => {
              return project.id;
            }
          );

          this._filterData.accountIds = this._filterData.accounts.map(
            (account) => {
              return account.id;
            }
          );

          this._filterData.resourceIds = this._filterData.resources.map(
            (resource) => {
              return resource.id;
            }
          );

          this._filterData.roleIds = this._filterData.roles.map((role) => {
            return role.id;
          });

          this._filterData.statusIds = this._filterData.status.map((status) => {
            return status.id;
          });

          this._filterData.typeIds = this._filterData.type.map((type) => {
            return type.id;
          });

          this._filterData.areaIds = this._filterData.area.map((area) => {
            return area.id;
          });

          this._filterData.projManagerIds = this._filterData.projManager.map(
            (projManager) => {
              return projManager.id;
            }
          );

          console.log("this._filterData==" + JSON.stringify(this._filterData));

          this.setFilterMessage();
          this.handleRefresh();
        })
        .catch((error) => {
          console.error(JSON.stringify(error));
          // this.handleRefresh();
          this.dispatchEvent(
            new ShowToastEvent({
              message: error.body.message,
              variant: "error"
            })
          );
        });
    });

    this.subscribeMC();
  }

  // catch blur on allocation menus
  closeDropdowns() {
    Array.from(this.template.querySelectorAll(".lwc-row-component")).forEach(
      (row) => {
        row.closeAllocationMenu();
      }
    );
  }

  // To set the gantt view type
  setGanttView() {
    this.isResourceOverview = false;
    //this.isRoleOverview = false;
    this.isProjectOverview = false;
    this.isResourceRecordView = false;
    this.isProjectRecordView = false;
    //this.currentView = '';

    console.log("this.defaultView==", this.defaultView);

    if (!this.currentView) {
      if (this.defaultView === "Resource")
        this.currentView = "resource-overview";
      else if (this.defaultView === "Project")
        this.currentView = "project-overview";
      else this.currentView = this.DEFAULT_GANTT_VIEW;
    }

    if (
      typeof this.objectApiName !== "undefined" &&
      this.objectApiName.endsWith("CCMI__Milestone_Project__c")
    ) {
      this.currentView = "project-record";
    } else if (
      typeof this.objectApiName !== "undefined" &&
      this.objectApiName.endsWith("User")
    ) {
      this.currentView = "resource-record";
    }

    switch (this.currentView) {
      case "project-overview":
        this.isProjectOverview = true;
        break;
      case "resource-overview":
        this.isResourceOverview = true;
        break;
      case "project-record":
        this.isProjectRecordView = true;
        break;
      case "resource-record":
        this.isResourceRecordView = true;
    }
  }

  toggleGanttView() {
    if (this.currentView === "project-overview")
      this.currentView = "resource-overview";
    else if (this.currentView === "resource-overview")
      this.currentView = "project-overview";
    this.setGanttView();
    this.setFilterMessage();
    this.clearPagination();
    this.handleRefresh();
  }

  /*** Navigation ***/
  setStartDate(_startDate) {
    console.log("_startDate==" + _startDate);
    //if (_startDate instanceof Date && !isNaN(_startDate)) {
    if (!isNaN(_startDate)) {
      _startDate.startOf("day");
      console.log("_startDate = " + _startDate);
      console.log("_startDate string = " + _startDate.toString());
      console.log("typeof _startDate==" + typeof _startDate);
      //_startDate.setHours(0, 0, 0, 0);

      //_startDate = new Date(Date.UTC(_startDate.getFullYear(), _startDate.getMonth(), _startDate.getDate(), 0, 0, 0));
      console.log("R3>>> _startDate = " + _startDate);

      //this.datePickerString = _startDate.toISOString();
      this.datePickerString = _startDate.format();

      //this.startDate = moment(_startDate).day(1).toDate();
      this.startDate = _startDate.subtract(1, "days").day(1).toDate();

      this.startDateUTC = _startDate + "";
      //this.startDateUTC = moment(this.startDate).utc().valueOf() - moment(this.startDate).utcOffset() * 60 * 1000 + "";

      //this.formattedStartDate = this.startDate.toLocaleDateString();
      this.formattedStartDate = _startDate.format("DD/MM/YYYY");
      console.log("formattedStartDate==" + this.formattedStartDate);

      console.log("R3>>> startDate = " + this.startDate);
      console.log("R3>>> startDateUTC = " + this.startDateUTC.toString());

      this.setDateHeaders();
    } else {
      this.dispatchEvent(
        new ShowToastEvent({
          message: "Invalid Date",
          variant: "error"
        })
      );
    }
  }

  setDateHeaders() {
    let _endDate = moment(this.startDate).add(
      this.view.slots * this.view.slotSize - 1,
      "days"
    );
    this.endDate = _endDate.toDate();
    this.endDateUTC = _endDate + "";
    //this.endDateUTC = moment(this.endDate).utc().valueOf() + ""; //- moment(this.endDate).utcOffset() * 60 * 1000 + "";
    console.log("endDateUTC==" + this.endDateUTC.toString());
    //this.formattedEndDate = this.endDate.toLocaleDateString();
    this.formattedEndDate = _endDate.format("DD/MM/YYYY");
    console.log("formattedEndDate==" + this.formattedEndDate);

    const dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    //let today = new Date();
    //today.setHours(0, 0, 0, 0);
    //today = today.getTime();
    let today = moment().startOf("day").toDate();

    let dates = {};

    for (
      let date = moment(this.startDate);
      date <= moment(this.endDate);
      date.add(this.view.slotSize, "days")
    ) {
      let index = date.format("YYYYMM");
      if (!dates[index]) {
        dates[index] = {
          dayName: "",
          name: date.format("MMMM"),
          days: []
        };
      }

      let day = {
        class:
          "slds-col slds-p-vertical_x-small slds-m-top_x-small lwc-timeline_day",
        //label: date.format("M/D"),
        label: date.format("D/M"),
        start: date.toDate()
      };

      if (this.view.slotSize > 1) {
        let end = moment(date).add(this.view.slotSize - 1, "days");
        day.end = end.toDate();
      } else {
        day.end = date.toDate();
        day.dayName = date.format("ddd");
        if (date.day() === 0) {
          day.class += " lwc-is-week-end";
          day.class += " lwc-is-disabled";
        } else if (date.day() === 6) {
          day.class += " lwc-is-disabled";
        }
      }

      if (today >= day.start && today <= day.end) {
        day.class += " lwc-is-today";
      }

      dates[index].days.push(day);
      dates[index].style =
        "width: calc(" +
        dates[index].days.length +
        "/" +
        this.view.slots +
        "*100%)";
    }

    // reorder index
    this.dates = Object.values(dates);

    Array.from(this.template.querySelectorAll("c-gantt_chart_row")).forEach(
      (row) => {
        row.refreshDates(this.startDate, this.endDate, this.view.slotSize);
      }
    );
  }

  navigateToToday() {
    //this.setStartDate(new Date());
    this.setStartDate(moment());
    this.handleRefresh();
  }

  navigateToPrevious() {
    let _startDate = new Date(this.startDate);
    _startDate.setDate(_startDate.getDate() - this.dateShift);

    let _start = moment(this.startDate).subtract(this.dateShift, "days");
    this.setStartDate(_start);

    //this.setStartDate(_startDate);
    this.handleRefresh();
  }

  navigateToNext() {
    let _startDate = new Date(this.startDate);
    _startDate.setDate(_startDate.getDate() + this.dateShift);

    let _start = moment(this.startDate).add(this.dateShift, "days");
    this.setStartDate(_start);

    //this.setStartDate(_startDate);
    this.handleRefresh();
  }

  navigateToDay(event) {
    //this.setStartDate(new Date(event.target.value + "T00:00:00"));
    this.setStartDate(moment(event.target.value + "T00:00:00"));
    this.handleRefresh();
  }

  setTimelineView(value) {
    let values = value.split("/");
    this.view.value = value;
    this.view.slotSize = parseInt(value[0], 10);
    this.view.slots = parseInt(values[1], 10);
  }

  handleViewChange(event) {
    this.setTimelineView(event.target.value);
    this.setDateHeaders();
    this.handleRefresh();
  }
  /*** /Navigation ***/

  /*** Pagination for gantt rows ***/

  @track paginationData = {
    pageNumber: 0,
    rowsPerPage: this.DEFAULT_ROWS_PER_PAGE,
    isNextDisabled: true,
    isPreviousDisabled: true,
    rangeStart: 0,
    rangeEnd: 0,
    totalRows: 0,
    totalPages: 0,
    paginationText: ""
  };

  goToNextPage(event) {
    if (this.paginationData.pageNumber < this.paginationData.totalPages) {
      this.paginationData.pageNumber++;
      this.handleRefresh();
    }
  }
  goToPreviousPage(event) {
    if (this.paginationData.pageNumber > 0) {
      this.paginationData.pageNumber--;
      this.handleRefresh();
    }
  }

  handlePageSizeChange(event) {
    this.paginationData.rowsPerPage = event.detail.value;
  }

  handlePageSizeChangeRefresh(event) {
    //this.paginationData.rowsPerPage = event.detail.value;
    this.handleRefresh();
  }

  setPagination(totalRows) {
    if (totalRows != null) this.paginationData.totalRows = totalRows;
    else totalRows = this.paginationData.totalRows;

    let rowsPerPage = this.paginationData.rowsPerPage;
    this.paginationData.totalPages = Math.ceil(totalRows / rowsPerPage) - 1;
    let pageNumber = this.paginationData.pageNumber;
    this.paginationData.rangeStart = pageNumber * rowsPerPage + 1;
    this.paginationData.rangeEnd = Math.min(
      totalRows,
      (pageNumber + 1) * rowsPerPage
    );
    this.paginationData.paginationText =
      "Showing " +
      this.paginationData.rangeStart +
      "-" +
      this.paginationData.rangeEnd +
      " of " +
      totalRows;

    this.paginationData.isNextDisabled = true;
    this.paginationData.isPreviousDisabled = true;
    if (this.paginationData.pageNumber > 0)
      this.paginationData.isPreviousDisabled = false;
    if (this.paginationData.pageNumber < this.paginationData.totalPages)
      this.paginationData.isNextDisabled = false;
  }

  clearPagination() {
    this.paginationData.pageNumber = 0;
    // this.setPagination();
  }
  /*** /Pagination for gantt rows ***/

  /*** Filter Modal ***/
  stopProp(event) {
    event.stopPropagation();
  }

  clearFocus() {
    this.filterModalData.focus = null;
  }

  openFilterModal() {
    this.filterModalData.projects = Object.assign(
      [],
      this._filterData.projects
    );
    this.filterModalData.accounts = Object.assign(
      [],
      this._filterData.accounts
    );
    this.filterModalData.resources = Object.assign(
      [],
      this._filterData.resources
    );
    this.filterModalData.roles = Object.assign([], this._filterData.roles);
    this.filterModalData.status = Object.assign([], this._filterData.status);
    this.filterModalData.type = Object.assign([], this._filterData.type);
    this.filterModalData.area = Object.assign([], this._filterData.area);
    this.filterModalData.projManager = Object.assign(
      [],
      this._filterData.projManager
    );
    this.filterModalData.account = Object.assign({}, this._filterData.account);
    console.log(
      "this.filterModalData== " + JSON.stringify(this.filterModalData)
    );
    this.setFilterModalDataDisable();
    this.template.querySelector(".filter-modal").show();
  }

  filterResources(event) {
    this.hideDropdowns();
    let text = event.target.value;

    getResources().then((resources) => {
      console.log("resources from apex== " + JSON.stringify(resources));
      console.log(
        "this.filterModalData.resources== " +
          JSON.stringify(this.filterModalData.resources)
      );
      console.log(
        "this.filterModalData.roles== " +
          JSON.stringify(this.filterModalData.roles)
      );

      // only show resource not selected
      //this.filterModalData.resourceOptions = resources.filter((resource) => {
      this.filterModalData.resourceOptions = resources.filter((resource) => {
        return (
          resource.name &&
          resource.name.toLowerCase().includes(text.toLowerCase()) &&
          !this.filterModalData.resources.filter((r) => {
            return r.id === resource.id;
          }).length // &&
          //!this.filterModalData.roles.filter((rr) => {
          //   return rr.id === resource.user.UserRoleId;
          // }).length
        );
      });
      console.log(
        "this.filterModalData.resourceOptions = " +
          JSON.stringify(this.filterModalData.resourceOptions)
      );
      this.filterModalData.focus = "resources";
    });
  }

  filterRoles(event) {
    this.hideDropdowns();
    let text = event.target.value;

    getRoles().then((roles) => {
      console.log("roles from apex== " + JSON.stringify(roles));
      console.log(
        "this.filterModalData.roles== " +
          JSON.stringify(this.filterModalData.roles)
      );

      // only show role not selected
      this.filterModalData.roleOptions = roles.filter((role) => {
        return (
          role.name &&
          role.name.toLowerCase().includes(text.toLowerCase()) &&
          !this.filterModalData.roles.filter((r) => {
            return r.id === role.id;
          }).length
        );
      });
      console.log(
        "this.filterModalData.roleOptions = " +
          JSON.stringify(this.filterModalData.roleOptions)
      );
      this.filterModalData.focus = "roles";
    });
  }

  filterProjects(event) {
    this.hideDropdowns();
    let text = event.target.value;

    getProjects().then((projects) => {
      // only show projects not selected
      this.filterModalData.projectOptions = projects.filter((project) => {
        return (
          project.name &&
          project.name.toLowerCase().includes(text.toLowerCase()) &&
          !this.filterModalData.projects.filter((p) => {
            return p.id === project.id;
          }).length
        );
      });
      this.filterModalData.focus = "projects";
    });
  }

  filterAccounts(event) {
    this.hideDropdowns();
    let text = event.target.value;

    getAccounts().then((accounts) => {
      // only show accounts not selected
      this.filterModalData.accountOptions = accounts.filter((account) => {
        return (
          account.name &&
          account.name.toLowerCase().includes(text.toLowerCase()) &&
          !this.filterModalData.accounts.filter((a) => {
            return a.id === account.id;
          }).length
        );
      });
      this.filterModalData.focus = "accounts";
    });
  }

  filterStatus(event) {
    this.hideDropdowns();
    let text = event.target.value;

    getStatus().then((status) => {
      // only show status not selected
      this.filterModalData.statusOptions = status.filter((singleStatus) => {
        return (
          singleStatus.name &&
          singleStatus.name.toLowerCase().includes(text.toLowerCase()) &&
          !this.filterModalData.status.filter((s) => {
            return s.id === singleStatus.id;
          }).length
        );
      });
      this.filterModalData.focus = "status";
    });
  }

  filterType(event) {
    this.hideDropdowns();
    let text = event.target.value;

    getType().then((type) => {
      // only show type not selected
      this.filterModalData.typeOptions = type.filter((singleType) => {
        return (
          singleType.name &&
          singleType.name.toLowerCase().includes(text.toLowerCase()) &&
          !this.filterModalData.type.filter((t) => {
            return t.id === singleType.id;
          }).length
        );
      });
      this.filterModalData.focus = "type";
    });
  }

  filterArea(event) {
    this.hideDropdowns();
    let text = event.target.value;

    getArea().then((area) => {
      // only show area not selected
      this.filterModalData.areaOptions = area.filter((singleArea) => {
        return (
          singleArea.name &&
          singleArea.name.toLowerCase().includes(text.toLowerCase()) &&
          !this.filterModalData.area.filter((a) => {
            return a.id === singleArea.id;
          }).length
        );
      });
      this.filterModalData.focus = "area";
    });
  }

  filterProjManager(event) {
    this.hideDropdowns();
    let text = event.target.value;

    getProjManager().then((projManager) => {
      // only show ProjManager not selected
      this.filterModalData.projManagerOptions = projManager.filter(
        (singleProjManager) => {
          return (
            singleProjManager.name &&
            singleProjManager.name.toLowerCase().includes(text.toLowerCase()) &&
            !this.filterModalData.projManager.filter((p) => {
              return p.id === singleProjManager.id;
            }).length
          );
        }
      );
      this.filterModalData.focus = "projManager"; //NOTE: might need to check this.
    });
  }

  addResourceFilter(event) {
    this.filterModalData.resources.push(
      Object.assign({}, event.currentTarget.dataset)
    );
    this.filterModalData.focus = null;
    this.setFilterModalDataDisable();
  }
  removeResourceFilter(event) {
    this.filterModalData.resources.splice(event.currentTarget.dataset.index, 1);
    this.setFilterModalDataDisable();
  }

  addRoleFilter(event) {
    this.filterModalData.roles.push(
      Object.assign({}, event.currentTarget.dataset)
    );
    this.filterModalData.focus = null;
    this.setFilterModalDataDisable();
  }
  removeRoleFilter(event) {
    this.filterModalData.roles.splice(event.currentTarget.dataset.index, 1);
    this.setFilterModalDataDisable();
  }

  addProjectFilter(event) {
    this.filterModalData.projects.push(
      Object.assign({}, event.currentTarget.dataset)
    );
    this.filterModalData.focus = null;
    this.setFilterModalDataDisable();
  }
  removeProjectFilter(event) {
    this.filterModalData.projects.splice(event.currentTarget.dataset.index, 1);
    this.setFilterModalDataDisable();
  }

  addAccountFilter(event) {
    this.filterModalData.accounts.push(
      Object.assign({}, event.currentTarget.dataset)
    );
    this.filterModalData.focus = null;
    this.setFilterModalDataDisable();
  }
  removeAccountFilter(event) {
    this.filterModalData.accounts.splice(event.currentTarget.dataset.index, 1);
    this.setFilterModalDataDisable();
  }

  addStatusFilter(event) {
    this.filterModalData.status.push(
      Object.assign({}, event.currentTarget.dataset)
    );
    this.filterModalData.focus = null;
    this.setFilterModalDataDisable();
  }
  removeStatusFilter(event) {
    this.filterModalData.status.splice(event.currentTarget.dataset.index, 1);
    this.setFilterModalDataDisable();
  }

  addTypeFilter(event) {
    this.filterModalData.type.push(
      Object.assign({}, event.currentTarget.dataset)
    );
    this.filterModalData.focus = null;
    this.setFilterModalDataDisable();
  }
  removeTypeFilter(event) {
    this.filterModalData.type.splice(event.currentTarget.dataset.index, 1);
    this.setFilterModalDataDisable();
  }

  addAreaFilter(event) {
    this.filterModalData.area.push(
      Object.assign({}, event.currentTarget.dataset)
    );
    this.filterModalData.focus = null;
    this.setFilterModalDataDisable();
  }
  removeAreaFilter(event) {
    this.filterModalData.area.splice(event.currentTarget.dataset.index, 1);
    this.setFilterModalDataDisable();
  }

  addProjManagerFilter(event) {
    this.filterModalData.projManager.push(
      Object.assign({}, event.currentTarget.dataset)
    );
    this.filterModalData.focus = null;
    this.setFilterModalDataDisable();
  }
  removeProjManagerFilter(event) {
    this.filterModalData.projManager.splice(
      event.currentTarget.dataset.index,
      1
    );
    this.setFilterModalDataDisable();
  }
  /*
  setAccountFilter(event) {
    console.log("event==" + JSON.stringify(event));
    // this.filterModalData.account = event.detail.id;
    this.filterModalData.account = {
      id: event.detail.id,
      name: event.detail.name
    };
    this.setFilterModalDataDisable();
  }
  removeAccountFilter(event) {
    console.log("event==" + JSON.stringify(event));
    this.filterModalData.account = { id: "", name: "" };
    this.setFilterModalDataDisable();
  }
*/

  clearFilters() {
    this.filterModalData.projects = [];
    this.filterModalData.projectSearch = "";
    this.filterModalData.accounts = [];
    this.filterModalData.accountSearch = "";
    this.filterModalData.resources = [];
    this.filterModalData.resourceSearch = "";
    this.filterModalData.roles = [];
    this.filterModalData.roleSearch = "";
    this.filterModalData.status = [];
    this.filterModalData.statusSearch = "";
    this.filterModalData.type = [];
    this.filterModalData.typeSearch = "";
    this.filterModalData.area = [];
    this.filterModalData.areaSearch = "";
    this.filterModalData.projManager = [];
    this.filterModalData.projManagerSearch = "";
    /*this.filterModalData.account = { id: "", name: "" };*/
    this.filterModalData.disabled = true;

    Array.from(this.template.querySelectorAll("c-custom-lookup")).forEach(
      (lookupFilter) => {
        lookupFilter.removeSelection();
      }
    );
  }

  setFilterModalDataDisable() {
    this.filterModalData.disabled = true;

    if (
      this.filterModalData.projects.length > 0 ||
      this.filterModalData.resources.length > 0 ||
      this.filterModalData.roles.length > 0 ||
      this.filterModalData.status.length > 0 ||
      this.filterModalData.type.length > 0 ||
      this.filterModalData.area.length > 0 ||
      this.filterModalData.projManager.length > 0 ||
      this.filterModalData.accounts.length > 0
    ) {
      this.filterModalData.disabled = false;
    }
  }

  hideDropdowns() {
    // prevent menu from closing if focused
    if (this.filterModalData.focus) {
      return;
    }
    this.filterModalData.projectOptions = [];
    this.filterModalData.accountOptions = [];
    this.filterModalData.resourceOptions = [];
    this.filterModalData.roleOptions = [];
    this.filterModalData.statusOptions = [];
    this.filterModalData.typeOptions = [];
    this.filterModalData.areaOptions = [];
    this.filterModalData.projManagerOptions = [];
  }

  applyFilters() {
    this._filterData = {
      projects: Object.assign([], this.filterModalData.projects),
      accounts: Object.assign([], this.filterModalData.accounts),
      resources: Object.assign([], this.filterModalData.resources),
      roles: Object.assign([], this.filterModalData.roles),
      status: Object.assign([], this.filterModalData.status),
      type: Object.assign([], this.filterModalData.type),
      area: Object.assign([], this.filterModalData.area),
      projManager: Object.assign([], this.filterModalData.projManager)
    };

    this._filterData.projectIds = this._filterData.projects.map((project) => {
      return project.id;
    });

    this._filterData.accountIds = this._filterData.accounts.map((account) => {
      return account.id;
    });

    this._filterData.resourceIds = this._filterData.resources.map(
      (resource) => {
        return resource.id;
      }
    );

    this._filterData.roleIds = this._filterData.roles.map((role) => {
      return role.id;
    });

    this._filterData.statusIds = this._filterData.status.map((status) => {
      return status.id;
    });

    this._filterData.typeIds = this._filterData.type.map((type) => {
      return type.id;
    });

    this._filterData.areaIds = this._filterData.area.map((area) => {
      return area.id;
    });

    this._filterData.projManagerIds = this._filterData.projManager.map(
      (projManager) => {
        return projManager.id;
      }
    );

    this.setFilterMessage();

    let self = this;
    setGanttChartSettings({
      filterResources: JSON.stringify(self._filterData.resources),
      filterProjects: JSON.stringify(self._filterData.projects),
      filterAccounts: JSON.stringify(self._filterData.accounts),
      filterRoles: JSON.stringify(self._filterData.roles),
      filterStatus: JSON.stringify(self._filterData.status),
      filterType: JSON.stringify(self._filterData.type),
      filterArea: JSON.stringify(self._filterData.area),
      filterProjManager: JSON.stringify(self._filterData.projManager)
    })
      .then(() => {
        console.log("Filters saved to custom settings");
      })
      .catch((error) => {
        console.error(JSON.stringify(error));
        /* this.dispatchEvent(
                new ShowToastEvent({
                    message: error.body.message,
                    variant: "error"
                })
            ); */
      });
    this.clearPagination();
    this.handleRefresh();
    this.template.querySelector(".filter-modal").hide();
  }

  setFilterMessage() {
    let filters = [];
    if (this._filterData.resources.length && this.isResourceOverview) {
      filters.push("Resources");
    }
    if (this._filterData.roles.length && this.isResourceOverview) {
      filters.push("Roles");
    }
    if (this._filterData.projects.length) {
      filters.push("Projects");
    }
    if (this._filterData.accounts.length) {
      filters.push("Accounts");
    }
    if (this._filterData.status.length) {
      filters.push("Status");
    }
    if (this._filterData.type.length) {
      filters.push("Type");
    }
    if (this._filterData.area.length) {
      filters.push("Area");
    }
    if (this._filterData.projManager.length) {
      filters.push("Project Manager");
    }
    /*if (this._filterData.account.id) {
      filters.push("Account");
    }*/

    if (filters.length) {
      this._filterData.message = "Filtered By " + filters.join(", ");
    }
  }
  /*** /Filter Modal ***/

  handleRefresh() {
    // refreshApex(this.wiredData);
    this.isLoading = true;
    this.ganttRows = [];
    let self = this;

    getGanttChartData({
      recordId: self.recordId ? self.recordId : "",
      viewMode: self.currentView,
      startTime: self.startDateUTC,
      endTime: self.endDateUTC,
      slotSize: self.view.slotSize,
      pageNumber: self.paginationData.pageNumber,
      recordsPerPage: self.paginationData.rowsPerPage,
      filterResources: self._filterData.resourceIds,
      filterRoles: self._filterData.roleIds,
      filterProjects: self._filterData.projectIds,
      filterStatus: self._filterData.statusIds,
      filterType: self._filterData.typeIds,
      filterArea: self._filterData.areaIds,
      filterProjManager: self._filterData.projManagerIds,
      filterAccounts: self._filterData.accountIds
    })
      .then((data) => {
        //self.projectId = data.projectId;

        // empty old data present in the variable
        if (self.ganttRows.length) {
          self.ganttRows.splice(0, self.ganttRows.length);
        }

        self.ganttRows = JSON.parse(JSON.stringify(data.ganttRows));
        console.log("data.totalRows==", data.totalRows);
        self.setPagination(data.totalRows);
        self.isLoading = false;

        // Trying to fix disordered pagination
        if (this.delayTimeout) {
          // eslint-disable-next-line @lwc/lwc/no-async-operation
          clearTimeout(this.delayTimeout);
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {}, 0);
        // fix ends

        if (this.showOnlyUnAllocatedResource) {
          this.filterUnAllocatedResource();
        }
      })
      .catch((error) => {
        console.error(error);
        this.dispatchEvent(
          new ShowToastEvent({
            message: error.body.message,
            variant: "error"
          })
        );
        this.isLoading = false;
      });
  }

  @wire(MessageContext)
  messageContext;

  subscription = null; // taskUpdate Message Channel Subscription

  subscribeMC() {
    // LMS_Service.subscribeMC(this.subscription, this.taskUpdateHandler);
    // messageService.subscribeMC(this.subscription, this.taskUpdateHandler);
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.messageContext,
      REFRESH_GANTT_CHART_CHANNEL,
      (message) => this.handleRefresh(),
      { scope: APPLICATION_SCOPE }
    );

    this.subscription = subscribe(
      this.messageContext,
      SHOW_SPINNER_CHANNEL,
      (message) => {
        this.isLoading = message.isLoading;
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  handleUnAllocatedResourceChange(event) {
    // var toggleVal = cmp.find('inputToggle').get('v.value');
    // var isChecked = cmp.find('inputToggle').get('v.checked');
    console.log("this.ganttRows ->", this.ganttRows);

    this.showOnlyUnAllocatedResource = event.target.checked; // defaulted to false;
    console.log(event.target.checked);
    this.filterUnAllocatedResource();
    if (event.target.checked) {
      this.showOnlyUnAllocatedResource = true;
      //this.filterUnAllocatedResource();
      // filter the grid data to show only un allocated resources
      console.log(" checked -> ", event.target.checked);
    }
  }

  filterUnAllocatedResource() {
    //console.log("filterUnAllocatedResource: this.ganttRows ->", this.ganttRows);
    this.isLoading = true;

    let tempGanttRows = this.ganttRows;
    this.ganttRows = [];
    let unallocated = tempGanttRows.find(
      (unAlloc) => unAlloc.id === "unassigned"
    );

    // this.ganttRows = tempGanttRows.filter( res => { if( res.allocationsByProject ) {
    //     let projKeys = Object.keys(res.allocationsByProject);
    //     if(!projKeys || projKeys.length <= 0 ) {
    //         return res;
    //     }
    // } });
    tempGanttRows.forEach((row) => {
      if (row.allocationsByProject) {
        let projKeys = Object.keys(row.allocationsByProject);
        if (
          this.showOnlyUnAllocatedResource &&
          projKeys &&
          projKeys.length > 0
        ) {
          row.allocatedResource = true;
        } else {
          row.allocatedResource = false;
        }
      }
      if (row.id === "unassigned") {
        row.allocatedResource = false;
      }
    });
    this.ganttRows = tempGanttRows;

    // this.ganttRows.push(unallocated); // put back unallocated
    this.ganttRows = JSON.parse(JSON.stringify(this.ganttRows));
    this.isLoading = false;
  }
}