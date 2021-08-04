/**
 * @description       :
 * @author            :
 * @group             :
 * @last modified on  : 01-02-2021
 * @last modified by  : Jonny Harte
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   01-02-2021   Jonny Harte   Initial Version
 **/
public class r3CreatePurchaseOrderLineItemsForBom {
  @InvocableMethod
  public static void createBOMPurchaseOrderLines(Request[] requests) {
    List<Id> bomIds = new List<Id>();
    for (Request req : requests)
      bomIds.add(req.bomId);

    // get BOM items
    List<Project_BOM_Item__c> bomList = getBOMs(bomIds);
    createPurchaseOrderLines(bomList);
    createProjectTasks(bomList, null);
  }

  public static List<Project_BOM_Item__c> getBOMs(List<Id> bomIds) {
    // get BOM items
    return [
      SELECT
        Id,
        Product__c,
        Order_Qnty__c,
        Milestone_Project__c,
        Required_Date__c,
        Override_POL_Rules__c,
        On_Order_Other__c,
        Order_Request__c,
        Order_Request__r.Name,
        Order_Request__r.Delivery_To_Site_Date__c,
        Order_Request__r.Task__c,
        Product__r.Is_Kit__c,
        Product__r.Dont_Create_POL__c,
        Product__r.Name,
        Product__r.BORIS_Codes__c,
        Product__r.Labour_Cost__c,
        Product__r.Labour_Sell__c,
        Product__r.Implementor__c,
        Product__r.BORIS_Codes__r.Name,
        Product__r.BORIS_Codes__r.Worksheet_Codes__c,
        Product__r.BORIS_Codes__r.BORIS_Description__c,
        Product__r.BORIS_Code_Output__c,
        Product__r.Work_Type__c
      FROM Project_BOM_Item__c
      WHERE Id IN :bomIds
      ORDER BY Product__r.Family, Product__r.Name
    ];
  }

  public static List<Site_Asset_BOM_Join__c> getSABJs(List<Id> sabjIds) {
    // get SABJ items
    return [
      SELECT
        Id,
        Product_Kit_Name__c,
        Quantity__c,
        On_Order__c,
        Order_Qnty__c,
        Site_Asset__c,
        Site_Asset__r.Plot_Reference__c,
        Site_Asset_Name__c,
        Project_BOM_Item__c,
        Project_BOM_Item__r.Id,
        Project_BOM_Item__r.Milestone_Project__c,
        Project_BOM_Item__r.Order_Qnty__c,
        Project_BOM_Item__r.Required_Date__c,
        Project_BOM_Item__r.Override_POL_Rules__c,
        Project_BOM_Item__r.On_Order_Other__c,
        Project_BOM_Item__r.Order_Request__c,
        Project_BOM_Item__r.Order_Request__r.Name,
        Project_BOM_Item__r.Order_Request__r.Delivery_To_Site_Date__c,
        Project_BOM_Item__r.Order_Request__r.Task__c,
        Project_BOM_Item__r.Product__c,
        Project_BOM_Item__r.Product__r.Name,
        Project_BOM_Item__r.Product__r.Dont_Create_POL__c,
        Project_BOM_Item__r.Product__r.BORIS_Codes__c,
        Project_BOM_Item__r.Product__r.Labour_Cost__c,
        Project_BOM_Item__r.Product__r.Labour_Sell__c,
        Project_BOM_Item__r.Product__r.Implementor__c,
        Project_BOM_Item__r.Product__r.Is_Kit__c,
        Project_BOM_Item__r.Product__r.BORIS_Codes__r.Name,
        Project_BOM_Item__r.Product__r.BORIS_Codes__r.Worksheet_Codes__c,
        Project_BOM_Item__r.Product__r.BORIS_Codes__r.BORIS_Description__c,
        Project_BOM_Item__r.Product__r.BORIS_Code_Output__c,
        Project_BOM_Item__r.Product__r.Work_Type__c
      FROM Site_Asset_BOM_Join__c
      WHERE Id IN :sabjIds
      ORDER BY Project_BOM_Item__c
    ];
  }

  public static void createPurchaseOrderLines(List<Id> bomIds) {
    createPurchaseOrderLines(getBOMs(bomIds));
  }

  public static void createPurchaseOrderLines(
    List<Project_BOM_Item__c> bomList
  ) {
    List<Id> kitProductIdList = new List<Id>();
    List<Id> kitProductIdOverideList = new List<Id>();

    // split into kits and components...
    for (Project_BOM_Item__c bom : bomList) {
      if (bom.Product__r.Is_Kit__c) {
        if (
          bom.Override_POL_Rules__c // need to load all components for these
        )
          kitProductIdOverideList.add(bom.Product__c);
        else
          kitProductIdList.add(bom.Product__c); // need to load only componenst which match adopter for these
      }
    }

    // for kits we need to get the component products
    List<Product_Kit__c> productKits = new List<Product_Kit__c>();
    if (kitProductIdList.size() > 0)
      productKits.addAll(
        r3ProductKitAdopterHelper.getComponentProducts(
          bomList[0].Milestone_Project__c,
          null,
          kitProductIdList
        )
      );
    if (kitProductIdOverideList.size() > 0)
      //    productKits.addAll(r3ProductKitAdopterHelper.getAllComponentProducts(kitProductIdList));
      productKits.addAll(
        r3ProductKitAdopterHelper.getAllComponentProducts(
          kitProductIdOverideList
        )
      );
    System.debug(
      'r3CreatePurchaseOrderLineItemsForBom.createBOMPurchaseOrderLines: productKits sz:' +
      productKits.size()
    );
    System.debug(
      'r3CreatePurchaseOrderLineItemsForBom.createBOMPurchaseOrderLines: productKits: ' +
      productKits
    );

    // create POLs for each component product...
    Map<String, Purchase_Order_Line__c> polItemMap = new Map<String, Purchase_Order_Line__c>();
    List<CCMI__Milestone_Task__c> taskInsertList = new List<CCMI__Milestone_Task__c>(); // WI-0014
    List<Project_BOM_Item__c> bomUpdateList = new List<Project_BOM_Item__c>();
    for (Project_BOM_Item__c bom : bomList) {
      if (!bom.Product__r.Dont_Create_POL__c) {
        // don't create if flag set e.g. for Labour products
        if (bom.Product__r.Is_Kit__c) {
          for (Product_Kit__c productKit : productKits) {
            if (bom.Product__c == productKit.Parent_Product__c) {
              if (
                polItemMap.containsKey(
                  '' +
                  bom.Order_Request__c +
                  productKit.Salesforce_Product__c
                )
              ) {
                polItemMap.put(
                  '' +
                  bom.Order_Request__c +
                  productKit.Salesforce_Product__c,
                  updatePOL(
                    polItemMap.get(
                      '' +
                      bom.Order_Request__c +
                      productKit.Salesforce_Product__c
                    ),
                    bom.Order_Qnty__c * productKit.Quantity__c
                  )
                ); // add POL for kit component
              } else {
                polItemMap.put(
                  '' +
                  bom.Order_Request__c +
                  productKit.Salesforce_Product__c,
                  createPOL(
                    productKit.Salesforce_Product__c,
                    bom.Order_Qnty__c * productKit.Quantity__c,
                    bom
                  )
                ); // add POL for kit component
              }
            }
          }
        } else {
          if (
            polItemMap.containsKey('' + bom.Order_Request__c + bom.Product__c)
          ) {
            polItemMap.put(
              '' +
              bom.Order_Request__c +
              bom.Product__c,
              updatePOL(
                polItemMap.get('' + bom.Order_Request__c + bom.Product__c),
                bom.Order_Qnty__c
              )
            ); // add POL for kit component
          } else {
            polItemMap.put(
              '' +
              bom.Order_Request__c +
              bom.Product__c,
              createPOL(bom.Product__c, bom.Order_Qnty__c, bom)
            ); // add POL for kit component
          }
          //polInsertLst.add(createPOL(bom.Product__c, bom.Order_Qnty__c, bom));  // for top level components directly add POL record to the insert list
        }

        // reset BOM order (as order placed)
        Project_BOM_Item__c updateBom = new Project_BOM_Item__c();
        updateBom.Id = bom.Id;
        updateBom.Order_Qnty__c = 0;
        updateBom.Order_Request__c = null;
        bomUpdateList.add(updateBom);
      }
    }

    System.debug(
      'r3CreatePurchaseOrderLineItemsForBom.createBOMPurchaseOrderLines: polItemMap :' +
      polItemMap
    );
    System.debug(
      'r3CreatePurchaseOrderLineItemsForBom.createBOMPurchaseOrderLines: polItemMap sz:' +
      polItemMap.size()
    );
    if (!polItemMap.isEmpty())
      insert polItemMap.values();

    if (!bomUpdateList.isEmpty())
      update bomUpdateList;
  }

  public static void createProjectTasks(List<Id> bomIds, List<Id> sabjIds) {
    createProjectTasks(getBOMs(bomIds), getSABJs(sabjIds));
  }

  public static void createProjectTasks(
    List<Project_BOM_Item__c> bomList,
    List<Site_Asset_BOM_Join__c> sabjList
  ) {
    CCMI__Milestone_Task__c reqTask;
    Id ordReqId = null;

    List<CCMI__Milestone_Task__c> taskInsertList = new List<CCMI__Milestone_Task__c>();

    if (bomList != null && !bomList.isEmpty()) {
      // create task for each site asset bom item...

      // Get the Workstream (Project Area) from the first BOM in the list to add to tasks.
      String projectArea = bomlist[0].Product__r.Work_Type__c;

      for (Project_BOM_Item__c bom : bomList) {
        system.debug('R3>>> createProjectTasks - BOM: ' + bom);
        // get existing task (if there is one already linked to the materials/order request) [query only fires once in this loop!]
        if (reqTask == null && bom.Order_Request__r.Task__c != null)
          reqTask = [
            SELECT
              Id,
              Name,
              CCMI__Milestone_Project__c,
              BORIS_Codes__c,
              CCMI__Desired_Start__c,
              CCMI__Duration__c,
              Total_Labour_Cost__c,
              Total_Labour_Hours__c
            FROM CCMI__Milestone_Task__c
            WHERE Id = :bom.Order_Request__r.Task__c
            LIMIT 1
          ];
        system.debug(
          'R3>>> createProjectTasks:bomList before- reqTask: ' + reqTask
        );
        // update the task with this bom request
        reqTask = updateProjectTask(bom, reqTask, '', true, projectArea);
        system.debug(
          'R3>>> createProjectTasks:bomList after updateProjectTask- reqTask: ' +
          reqTask
        );

        // store order/material request (if it needs to be updated with task)
        if (
          ordReqId == null &&
          bom.Order_Request__c != null &&
          bom.Order_Request__r.Task__c == null
        )
          ordReqId = bom.Order_Request__c;
      }
    }

    if (sabjList != null && !sabjList.isEmpty()) {
      // create task for each site asset bom item...

      // Get the Workstream (Project Area) from the first sabj in the list to add to tasks.
      String projectArea = sabjList[0]
        .Project_BOM_Item__r.Product__r.Work_Type__c;

      for (Site_Asset_BOM_Join__c sabj : sabjList) {
        system.debug('R3>>> createProjectTasks - SABJ: ' + sabj);
        system.debug(
          'R3>>> createProjectTasks - Site Asset Reference: ' + sabj
        );
        // get existing task (if there is one already linked to the materials/order request) [query only fires once in this loop!]
        if (
          reqTask == null &&
          sabj.Project_BOM_Item__r.Order_Request__r.Task__c != null
        )
          reqTask = [
            SELECT
              Id,
              Name,
              CCMI__Milestone_Project__c,
              BORIS_Codes__c,
              CCMI__Desired_Start__c,
              CCMI__Duration__c,
              Total_Labour_Cost__c,
              Total_Labour_Hours__c
            FROM CCMI__Milestone_Task__c
            WHERE Id = :sabj.Project_BOM_Item__r.Order_Request__r.Task__c
            LIMIT 1
          ];

        // update the task with this bom request
        String plotRef = 'n/a';
        if (sabj.Site_Asset__r.Plot_Reference__c != null)
          plotRef = sabj.Site_Asset__r.Plot_Reference__c;
        system.debug('R3>>> createProjectTasks - Plot Reference: ' + plotRef);
        system.debug(
          'R3>>> createProjectTasks:sabjList before- reqTask: ' + reqTask
        );
        reqTask = updateProjectTask(
          sabj.Project_BOM_Item__r,
          reqTask,
          plotRef,
          false,
          projectArea
        );
        system.debug(
          'R3>>> createProjectTasks:sabjList after updateProjectTask- reqTask: ' +
          reqTask
        );
        // store order/material request (if it needs to be updated with task)
        if (
          ordReqId == null &&
          sabj.Project_BOM_Item__r.Order_Request__c != null &&
          sabj.Project_BOM_Item__r.Order_Request__r.Task__c == null
        )
          ordReqId = sabj.Project_BOM_Item__r.Order_Request__c;
      }
    }

    // update/insert task...
    if (reqTask != null)
      upsert reqTask;

    // update materials request with task...
    if (ordReqId != null && reqTask != null)
      update new Order_Request__c(Id = ordReqId, Task__c = reqTask.Id);
  }

  // WI-0014
  private static CCMI__Milestone_Task__c updateProjectTask(
    Project_BOM_Item__c bom,
    CCMI__Milestone_Task__c reqTask,
    String plotRef,
    Boolean updateCost,
    String projectArea
  ) {
    system.debug(
      'R3>>> r3CreatePurchaseOrderLineItemsForBom.updateProjectTask'
    );
    String Plots = '';
    R3_Settings__c settings = R3_Settings__c.getInstance();
    Decimal labourRate = settings.Labour_Cost_Day_Rate__c;
    Decimal HoursPerDay = settings.Labour_Hours_per_Day__c;
    if (labourRate == null || Test.isRunningTest())
      labourRate = 450; // default it to something if not set...
    if (HoursPerDay == null || Test.isRunningTest())
      HoursPerDay = 8; // default it to something if not set...

    // create project line item...
    if (bom.Milestone_Project__c == null || bom.Product__c == null) {
      system.debug(
        'R3>>> Cannot create BOM task as project and/or product are null!'
      );
    } else if (
      bom.Product__r.Labour_Cost__c == null ||
      bom.Product__r.Labour_Cost__c == 0
    ) {
      system.debug(
        'R3>>> No labour cost => no project task created! ' +
        bom.Product__r.Labour_Cost__c +
        ' ' +
        bom.Product__r.name
      );
    } else {
      system.debug('R3>>> bom.Product__r.name = ' + bom.Product__r.name);

      if (reqTask == null) {
        //reqTask = new CCMI__Milestone_Task__c(CCMI__Status__c = 'Active', Project_Area__c = 'Site Construction');
        reqTask = new CCMI__Milestone_Task__c(
          CCMI__Status__c = 'Active',
          Project_Area__c = projectArea
        );
        reqTask.CCMI__Milestone_Project__c = bom.Milestone_Project__c;
        system.debug(
          'R3>>> reqTask.CCMI__Milestone_Project__c = ' +
          reqTask.CCMI__Milestone_Project__c
        );

        reqTask.Name = bom.Order_Request__r.name; // set to order request name
        system.debug('R3>>> reqTask.Name = ' + reqTask.Name);

        if (bom.Product__r.BORIS_Code_Output__c != null) {
          reqTask.BORIS_Codes__c = bom.Product__r.BORIS_Code_Output__c;
          reqTask.BORIS_Codes__c = reqTask.BORIS_Codes__c.replaceAll('<PLOTREF>', plotRef);
        }
        system.debug(
          'R3>>> reqTask.BORIS_Codes__c = ' + reqTask.BORIS_Codes__c
        );

        reqTask.CCMI__Desired_Start__c = system.today() + 28; // default value for when the request date is not valid
        if (bom.Order_Request__r.Delivery_To_Site_Date__c != null)
          reqTask.CCMI__Desired_Start__c = bom.Order_Request__r.Delivery_To_Site_Date__c;
        system.debug(
          'R3>>> reqTask.CCMI__Desired_Start__c = ' +
          reqTask.CCMI__Desired_Start__c
        );

        reqTask.CCMI__Duration__c = 1;
        if (
          bom.Order_Qnty__c != null &&
          bom.Product__r.Implementor__c == 'Connect It'
        ) {
          // assign duration and labour costs only if the implementor is Connect It...
          Decimal LabourCost = bom.Product__r.Labour_Cost__c;
          Decimal Quantity = bom.Order_Qnty__c;

          // ensure we have a value!
          if (LabourCost == null || !updateCost)
            LabourCost = 0;

          // do calculations
          reqTask.Total_Labour_Cost__c = (LabourCost * Quantity);
          reqTask.Total_Labour_Hours__c = Math.ceil(
            ((reqTask.Total_Labour_Cost__c) / labourRate) * HoursPerDay
          );
          reqTask.CCMI__Duration__c = Math.Max(
            Math.ceil(reqTask.Total_Labour_Hours__c / HoursPerDay),
            1
          );

          // task is sent to BORIS if products incorporate a labour charge
          if (reqTask.Total_Labour_Cost__c > 0)
            reqTask.BORIS_job__c = true;
        }
        system.debug(
          'R3>>> reqTask.Total_Labour_Cost__c = ' + reqTask.Total_Labour_Cost__c
        );
        system.debug(
          'R3>>> reqTask.CCMI__Duration__c = ' + reqTask.CCMI__Duration__c
        );
      } else {
        if (bom.Product__r.BORIS_Code_Output__c != null) {
          String text = '';
          text = bom.Product__r.BORIS_Code_Output__c;
          text = text.replaceAll('<PLOTREF>', plotRef);

          if (
            reqTask.BORIS_Codes__c == null ||
            reqTask.BORIS_Codes__c.length() == 0
          )
            reqTask.BORIS_Codes__c = text;
          else if (!reqTask.BORIS_Codes__c.contains(text))
            reqTask.BORIS_Codes__c += ',' + text;
        }
        system.debug(
          'R3>>> reqTask.BORIS_Codes__c = ' + reqTask.BORIS_Codes__c
        );

        if (
          bom.Order_Qnty__c != null &&
          bom.Product__r.Implementor__c == 'Connect It' &&
          updateCost
        ) {
          // append duration and labour costs only if the implementor is Connect It...
          Decimal LabourCost = bom.Product__r.Labour_Cost__c;
          Decimal Quantity = bom.Order_Qnty__c;

          // ensure we have a value!
          if (LabourCost == null || !updateCost)
            LabourCost = 0;

          // do calculations
          reqTask.Total_Labour_Cost__c += (LabourCost * Quantity);
          reqTask.Total_Labour_Hours__c = Math.ceil(
            ((reqTask.Total_Labour_Cost__c) / labourRate) * HoursPerDay
          );
          reqTask.CCMI__Duration__c = Math.Max(
            Math.ceil(reqTask.Total_Labour_Hours__c / HoursPerDay),
            1
          );

          // task is sent to BORIS if products incorporate a labour charge
          if (reqTask.Total_Labour_Cost__c > 0)
            reqTask.BORIS_job__c = true;
        }
        system.debug(
          'R3>>> reqTask.Total_Labour_Cost__c = ' + reqTask.Total_Labour_Cost__c
        );
        system.debug(
          'R3>>> reqTask.CCMI__Duration__c = ' + reqTask.CCMI__Duration__c
        );
      }
    }

    return reqTask;
  }
  // WI-0014

  private static Purchase_Order_Line__c createPOL(
    Id ProductId,
    Decimal Quantity,
    Project_BOM_Item__c bom
  ) {
    Purchase_Order_Line__c pol = new Purchase_Order_Line__c();
    pol.Milestone_Project__c = bom.Milestone_Project__c;
    pol.Order_Request__c = bom.Order_Request__c;
    pol.POL_Status__c = 'New';
    pol.Product__c = ProductId;
    pol.Project_BOM_Item__c = bom.Id;
    pol.Quantity__c = Quantity;
    pol.Required_Delivery_Date__c = bom.Required_Date__c;
    System.debug('r3CreatePurchaseOrderLineItemsForBom.createPOL: pol :' + pol);
    return pol;
  }

  private static Purchase_Order_Line__c updatePOL(
    Purchase_Order_Line__c pol,
    Decimal quantity
  ) {
    pol.Quantity__c = pol.Quantity__c + quantity;
    System.debug('r3CreatePurchaseOrderLineItemsForBom.updatePOL: pol :' + pol);
    return pol;
  }

  public class request {
    @InvocableVariable(label='BOM ID' required=true)
    public Id bomId;
  }
}