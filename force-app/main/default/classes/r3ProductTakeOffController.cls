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
public without sharing class r3ProductTakeOffController {
  private static Integer Count;
  private static List<bomWrapper> bwl;

  @AuraEnabled
  public static String getBOMItemsTree(String projectId) {
    // Tree construct:
    // - Street Light 1
    //      - Electric
    //           - Product Kit 1
    //           - Product Kit 2
    //               - Product Component 1
    //               - Product Component 2
    //               - etc
    // - Charge Point 1
    //      - Electric
    //           - Product Kit 1
    //           - Product Kit 2
    //               - Product Component 1
    //               - Product Component 2
    //               - etc
    // - Plot 1
    //      - Water
    //      - Electric
    //           - Product Kit 1
    //           - Product Kit 2
    //               - Product Component 1
    //               - Product Component 2
    //               - etc
    //      - Gas
    // ---------------------------
    // - Estimate
    //      - Site
    //          - Product Family
    //              - Product Kit A
    //              - Product Kit B
    //                  - Product Component 1
    //                  - Product Component 2
    //

    Map<id, List<Product_Kit__c>> pbiMap = new Map<id, List<Product_Kit__c>>();
    List<Project_BOM_Item__c> topLevel = new List<Project_BOM_Item__c>();
    List<Project_BOM_Item__c> secondLevel = new List<Project_BOM_Item__c>();
    List<Id> EstimateProductIds = new List<Id>();

    System.debug(
      'r3ProductTakeOffController.getBOMItemsTree: projectId=' + projectId
    );

    // get BOM items...
    if (projectId == null || projectId == '')
      return '{}';

    // get links to site assets...
    List<Site_Asset_BOM_Join__c> siteAssetBomProductKits = [
      SELECT
        Id,
        Product_Kit_Name__c,
        Quantity__c,
        On_Order__c,
        Site_Asset__c,
        Site_Asset__r.Name,
        Site_Asset__r.Address__c,
        Project_BOM_Item__c,
        Project_BOM_Item__r.Id,
        Project_BOM_Item__r.Estimate_Product__c,
        Project_BOM_Item__r.Estimate_Product__r.OpportunityId__c,
        Project_BOM_Item__r.Estimate_Product__r.OpportunityId__r.Name,
        Project_BOM_Item__r.Estimate_Product_Id__c,
        Project_BOM_Item__r.BOM_Line_Item_Name__c,
        Project_BOM_Item__r.Name,
        Project_BOM_Item__r.Est_Qty__c,
        Project_BOM_Item__r.Milestone_Project__c,
        Project_BOM_Item__r.Lead_Time__c,
        Project_BOM_Item__r.Order_Qnty__c,
        Project_BOM_Item__r.Order_Request__c,
        Project_BOM_Item__r.Order_Status__c,
        Project_BOM_Item__r.Product__c,
        Project_BOM_Item__r.Product_Code__c,
        Project_BOM_Item__r.Product_Kit__c,
        Project_BOM_Item__r.Product_Name__c,
        Project_BOM_Item__r.Quantity__c,
        Project_BOM_Item__r.Required_Date__c,
        Project_BOM_Item__r.Take_Off__c,
        Project_BOM_Item__r.On_Order__c,
        Project_BOM_Item__r.On_Order_Other__c,
        Project_BOM_Item__r.On_Order_Site_Assets__c,
        Project_BOM_Item__r.Product_Kit__r.name,
        Project_BOM_Item__r.Product__r.Family,
        Project_BOM_Item__r.Product__r.Name,
        Project_BOM_Item__r.Product__r.ProductCode,
        Project_BOM_Item__r.Product__r.Lead_Time__c,
        Project_BOM_Item__r.Product__r.RecordTypeId,
        Project_BOM_Item__r.Product__r.RecordType.DeveloperName,
        Project_BOM_Item__r.Product__r.Sort__c,
        Project_BOM_Item__r.Take_Off_Quantity__c,
        Project_BOM_Item__r.Quantity_not_allocated__c,
        Project_BOM_Item__r.Quantity_Allocated__c
      FROM Site_Asset_BOM_Join__c
      WHERE Project_BOM_Item__r.Milestone_Project__c = :projectId
      ORDER BY
        Project_BOM_Item__r.Estimate_Product__r.OpportunityId__c,
        Site_Asset__c,
        Project_BOM_Item__r.Product__r.Family,
        Project_BOM_Item__r.Product__r.Name NULLS LAST
    ];
    System.debug(
      'r3ProductTakeOffController.getBOMItemsTree: siteAssetBomProductKits=' +
      siteAssetBomProductKits
    );

    // get BOM line items relating to this project...
    List<Project_BOM_Item__c> pbis = [
      SELECT
        Id,
        BOM_Line_Item_Name__c,
        Estimate_Product__c,
        Estimate_Product__r.OpportunityId__c,
        Estimate_Product__r.OpportunityId__r.Name,
        Estimate_Product_Id__c,
        Name,
        Est_Qty__c,
        Milestone_Project__c,
        Lead_Time__c,
        Order_Qnty__c,
        Order_Request__c,
        Order_Status__c,
        Product__c,
        Product_Code__c,
        Product_Kit__c,
        Product_Name__c,
        Quantity__c,
        Quantity_Allocated__c,
        Quantity_not_allocated__c,
        Required_Date__c,
        Take_Off__c,
        On_Order__c,
        On_Order_Other__c,
        On_Order_Site_Assets__c,
        Product_Kit__r.name,
        Product__r.Name,
        Product__r.ProductCode,
        Product__r.Lead_Time__c,
        Product__r.RecordTypeId,
        Product__r.RecordType.DeveloperName,
        Product__r.Sort__c,
        Product__r.Family,
        Take_Off_Quantity__c
      FROM Project_BOM_Item__c
      WHERE Milestone_Project__c = :projectId AND Quantity_not_allocated__c > 0
      ORDER BY Product__r.Family, Product__r.Name
    ];
    System.debug('r3ProductTakeOffController.getBOMItemsTree: pbis=' + pbis);

    // get product kit ids (from both site asset allocated and non-site asset allocated queries)
    Set<Id> pkIds = new Set<Id>();
    for (Site_Asset_BOM_Join__c sabj : siteAssetBomProductKits) {
      if (
        sabj.Project_BOM_Item__r.Product__r.recordType.DeveloperName == 'Kit'
      ) {
        pkIds.add(sabj.Project_BOM_Item__r.Product__c);
      }
    }
    for (Project_BOM_Item__c pbi : pbis) {
      if (pbi.Product__r.recordType.DeveloperName == 'Kit') {
        pkIds.add(pbi.Product__c);
      }
      estimateProductIds.add(pbi.Estimate_Product_Id__c);
    }

    System.debug('r3ProductTakeOffController.getBOMItemsTree: pkIds=' + pkIds);
    System.debug(
      'r3ProductTakeOffController.getBOMItemsTree: EstimateProductIds=' +
      estimateProductIds
    );

    // Create estimateProductId to Estimate Map
    //Map<String, Id> estimateProductEstimateMap = getEstimateProductEstimateMap(estimateProductIds);
    //System.debug('r3ProductTakeOffController.getBOMItemsTree: estimateProductEstimateMap='+estimateProductEstimateMap);

    List<Product_Kit__c> pkChilden = [
      SELECT
        Id,
        Name,
        Parent_Product__c,
        Quantity__c,
        Salesforce_Product__c,
        Salesforce_Product__r.Name,
        Salesforce_Product__r.ProductCode,
        Salesforce_Product__r.Allocated_Stock__c,
        Salesforce_Product__r.Free_Stock__c,
        Salesforce_Product__r.Lead_Time__c
      FROM Product_Kit__c
      WHERE Parent_Product__c IN :pkIds
    ];
    System.debug(
      'r3ProductTakeOffController.getBOMItemsTree: pkChilden=' + pkChilden
    );

    // Get all children and create pk to child list map
    List<Id> pkChildIds = new List<Id>();
    for (Product_Kit__c pk : pkChilden) {
      pkChildIds.add(pk.Id);

      // add child to map
      // if no prduct kit then it's a top level component product, so include it...

      if (!pbiMap.containsKey(pk.Parent_Product__c)) {
        pbiMap.put(pk.Parent_Product__c, new List<Product_Kit__c>());
        //secondLevel.add(pbi);
      }
    }

    // parse list for second level items (i.e. items WITH a kit product reference)
    for (Product_Kit__c pk : pkChilden) {
      id productId = pk.Salesforce_Product__c;
      id productKitId = pk.Parent_Product__c;

      if (pbiMap.containsKey(productKitId)) {
        pbiMap.get(productKitId).add(pk);
      }
    }
    System.debug(
      'r3ProductTakeOffController.getBOMItemsTree: pbiMap=' + pbiMap
    );

    bwl = new List<bomWrapper>();
    bomWrapper bwEstimate = null;
    bomWrapper bwSiteAsset = null;
    bomWrapper bwFamily = null;
    bomWrapper bwProductKit = null;
    Id estimateId = null;
    String siteAssetName = '';
    Id siteAssetId = null;
    String family = '';
    Id productKitId = null;
    Count = 0;
    for (Site_Asset_BOM_Join__c sabj : siteAssetBomProductKits) {
      System.debug(
        'r3ProductTakeOffController.getBOMItemsTree: in loop sabj Id=' +
        sabj.Id +
        ', Opportunity=' +
        sabj.Project_BOM_Item__r.Estimate_Product__r.OpportunityId__c +
        ', ' +
        sabj.Project_BOM_Item__r.Estimate_Product__r.OpportunityId__r.Name
      );

      // New Estimate Level?
      if (
        estimateId !=
        sabj.Project_BOM_Item__r.Estimate_Product__r.OpportunityId__c
      ) {
        // store items
        if (bwProductKit != null && bwFamily != null) {
          bwFamily.items.add(bwProductKit);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: in loop product kit added, ' +
            bwProductKit.ProductName
          );
          bwProductKit = null;
        }
        if (bwFamily != null && bwSiteAsset != null) {
          bwSiteAsset.items.add(bwFamily);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: in loop family added, ' +
            bwFamily.ProductName
          );
          bwFamily = null;
        }

        if (bwSiteAsset != null && bwEstimate != null) {
          bwEstimate.items.add(bwSiteAsset);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: in loop site asset added, ' +
            bwSiteAsset.ProductName
          );
          bwSiteAsset = null;
        }
        if (bwEstimate != null) {
          bwl.add(bwEstimate);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: in loop estimate added, ' +
            bwEstimate.ProductName
          );
          bwEstimate = null;
        }
        // create new (next) Estimate
        estimateId = sabj.Project_BOM_Item__r.Estimate_Product__r.OpportunityId__c;
        siteAssetName = '';
        siteAssetId = null;
        family = '';
        productKitId = null;
        bwEstimate = new bomWrapper(
          sabj.Project_BOM_Item__c,
          count++,
          sabj.Project_BOM_Item__r.Estimate_Product__r.OpportunityId__r.Name,
          estimateId,
          ''
        );

        System.debug(
          'r3ProductTakeOffController.getBOMItemsTree: in loop Estimate created, sabj.Project_BOM_Item__r.Estimate_Product__r.OpportunityId__c=' +
          sabj.Project_BOM_Item__r.Estimate_Product__r.OpportunityId__c
        );
      }

      // New Site Asset Level?
      if (siteAssetId != sabj.Site_Asset__c) {
        // store items
        if (bwProductKit != null && bwFamily != null) {
          bwFamily.items.add(bwProductKit);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: in loop product kit added, ' +
            bwProductKit.ProductName
          );
          bwProductKit = null;
        }
        if (bwFamily != null && bwSiteAsset != null) {
          bwSiteAsset.items.add(bwFamily);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: in loop family added, ' +
            bwFamily.ProductName
          );
          bwFamily = null;
        }
        if (bwSiteAsset != null && bwEstimate != null) {
          bwEstimate.items.add(bwSiteAsset);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: in loop site asset added, ' +
            bwSiteAsset.ProductName
          );
          bwSiteAsset = null;
        }

        // create new (next) site asset
        siteAssetId = sabj.Site_Asset__c;
        siteAssetName = sabj.Site_Asset__r.Name;

        family = '';
        productKitId = null;
        bwSiteAsset = new bomWrapper(
          sabj.Project_BOM_Item__c,
          count++,
          sabj.Site_Asset__r.Name,
          sabj.Site_Asset__c,
          sabj.Site_Asset__r.Address__c
        );

        System.debug(
          'r3ProductTakeOffController.getBOMItemsTree: in loop site asset created, ' +
          sabj.Site_Asset__r.Name
        );
      }

      // New Product Family level?
      if (family != sabj.Project_BOM_Item__r.Product__r.Family) {
        // store items
        if (bwProductKit != null && bwFamily != null) {
          bwFamily.items.add(bwProductKit);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: in loop product kit added, ' +
            bwProductKit.ProductName
          );
          bwProductKit = null;
        }
        if (bwFamily != null && bwSiteAsset != null) {
          bwSiteAsset.items.add(bwFamily);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: in loop family added, ' +
            bwFamily.ProductName
          );
          bwFamily = null;
        }

        // create new (next) product family item
        family = sabj.Project_BOM_Item__r.Product__r.Family;
        productKitId = null;
        bwFamily = new bomWrapper(
          sabj.Project_BOM_Item__c,
          count++,
          sabj.Project_BOM_Item__r.Product__r.Family,
          projectId
        );
        System.debug(
          'r3ProductTakeOffController.getBOMItemsTree: in loop family created, ' +
          sabj.Project_BOM_Item__r.Product__r.Family
        );
      }

      // New Product Kit Level
      if (productKitId != sabj.Project_BOM_Item__r.Product__c) {
        // store product kit item
        if (bwProductKit != null && bwFamily != null) {
          bwFamily.items.add(bwProductKit);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: in loop product kit added, ' +
            bwProductKit.ProductName
          );
          bwProductKit = null;
        }

        // create new (next) product kit item
        productKitId = sabj.Project_BOM_Item__r.Product__c;
        bwProductKit = new bomWrapper(
          sabj.Id, // bom join
          sabj.Project_BOM_Item__c,
          count++,
          sabj.Project_BOM_Item__r.Product__r.Name,
          sabj.Project_BOM_Item__c,
          sabj.Quantity__c,
          sabj.Project_BOM_Item__r.Product__r.ProductCode,
          sabj.Project_BOM_Item__r.Product__r.Lead_Time__c,
          sabj.On_Order__c,
          sabj.Project_BOM_Item__r.Product__c,
          siteAssetName
        );
        if (pbiMap.get(sabj.Project_BOM_Item__r.Product__c) != null) {
          bwProductKit.items = getBomWrapperChildList(
            pbiMap.get(sabj.Project_BOM_Item__r.Product__c),
            pbiMap,
            sabj.Quantity__c
          );
        }
        System.debug(
          'r3ProductTakeOffController.getBOMItemsTree: in loop product kit created, ' +
          sabj.Project_BOM_Item__r.Product__r.Name
        );
        System.debug(
          'r3ProductTakeOffController.getBOMItemsTree: in loop product kit siteAssetName, ' +
          siteAssetName
        );
      }
    }

    // finish up...

    if (bwProductKit != null && bwFamily != null) {
      count++;
      bwFamily.items.add(bwProductKit);
      System.debug(
        'r3ProductTakeOffController.getBOMItemsTree: product kit added (final):' +
        bwProductKit
      );
    }
    if (bwFamily != null && bwSiteAsset != null) {
      count++;
      bwSiteAsset.items.add(bwFamily);
      System.debug(
        'r3ProductTakeOffController.getBOMItemsTree: family added (final):' +
        bwSiteAsset
      );
    }
    if (bwSiteAsset != null && bwEstimate != null) {
      count++;
      bwEstimate.items.add(bwSiteAsset);
      System.debug(
        'r3ProductTakeOffController.getBOMItemsTree: site asset added (final):' +
        bwSiteAsset
      );
    }
    if (bwEstimate != null) {
      count++;
      bwl.add(bwEstimate);
      System.debug(
        'r3ProductTakeOffController.getBOMItemsTree: Estimate added (final):' +
        bwEstimate
      );
    }

    // get the BOM items Ids
    bwSiteAsset = new bomWrapper(null, count++, 'Other', projectId);
    bwFamily = null;
    bwProductKit = null;
    //Id siteAssetId = null;
    family = '';
    productKitId = null;
    for (Project_BOM_Item__c pbi : pbis) {
      if (family != pbi.Product__r.Family) {
        // store items
        if (bwProductKit != null) {
          bwFamily.items.add(bwProductKit);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: product kit added, ' +
            bwProductKit.ProductName
          );
          bwProductKit = null;
        }
        if (bwFamily != null && bwSiteAsset != null) {
          bwSiteAsset.items.add(bwFamily);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: family added, ' +
            bwFamily.ProductName
          );
          bwFamily = null;
        }

        // create new (next) product family item
        family = pbi.Product__r.Family;
        productKitId = null;
        bwFamily = new bomWrapper(
          pbi.Id,
          count++,
          pbi.Product__r.Family,
          projectId
        );
        System.debug(
          'r3ProductTakeOffController.getBOMItemsTree: family created, ' +
          pbi.Product__r.Family
        );
      }

      if (productKitId != pbi.Product__c) {
        // store product kit item
        if (bwProductKit != null) {
          bwFamily.items.add(bwProductKit);
          System.debug(
            'r3ProductTakeOffController.getBOMItemsTree: product kit added, ' +
            bwProductKit.ProductName
          );
          bwProductKit = null;
        }

        // create new (next) product kit item
        productKitId = pbi.Product__c;
        bwProductKit = new bomWrapper(
          pbi.Id,
          count++,
          pbi.Product__r.Name,
          pbi.Id,
          pbi.Quantity_not_allocated__c,
          pbi.Product__r.ProductCode,
          pbi.Product__r.Lead_Time__c,
          pbi.On_Order_Other__c, //pbi.On_Order__c, //pbi.Quantity_not_allocated__c, // KF ??
          pbi.Product__c,
          null
        );
        if (pbiMap.get(pbi.Product__c) != null) {
          bwProductKit.items = getBomWrapperChildList(
            pbiMap.get(pbi.Product__c),
            pbiMap,
            pbi.Quantity_not_allocated__c
          ); // KF 11/03/2020 pbi.Est_Qty__c);
        }
        System.debug(
          'r3ProductTakeOffController.getBOMItemsTree: product kit created, ' +
          pbi.Product__r.Name
        );
      }
    }

    // finish up...
    if (bwProductKit != null) {
      count++;
      bwFamily.items.add(bwProductKit);
      System.debug(
        'r3ProductTakeOffController.getBOMItemsTree: product kit added (final)'
      );
    }
    if (bwFamily != null) {
      count++;
      bwSiteAsset.items.add(bwFamily);
      System.debug(
        'r3ProductTakeOffController.getBOMItemsTree: family added (final)'
      );
    }
    if (bwSiteAsset != null) {
      count++;
      bwl.add(bwSiteAsset);
      System.debug(
        'r3ProductTakeOffController.getBOMItemsTree: site asset added (final)'
      );
    }

    if (bwl.isEmpty())
      return '{}';
    System.debug(
      'r3ProductTakeOffController.getBOMItemsTree: return=' +
      JSON.serializePretty(bwl)
    );
    return JSON.serializePretty(bwl);
  }

  @AuraEnabled
  public static String updateBOM(
    List<bomWrapper> orderData,
    Id materialsRequest,
    Id projectId
  ) {
    System.debug(
      'r3ProductTakeOffController.updateBOM: materialsRequest=*' +
      materialsRequest +
      '*'
    );
    System.debug(
      'r3ProductTakeOffController.updateBOM: orderData=' + orderData
    );
    List<Project_BOM_Item__c> boms = new List<Project_BOM_Item__c>();
    List<Project_BOM_Item__c> updateBoms = new List<Project_BOM_Item__c>();
    List<Project_BOM_Item__c> bomUpdateList = new List<Project_BOM_Item__c>();

    // collate total quantity for each bom item (there may be multiple entries)
    Map<Id, Decimal> bomItemOrderMap = new Map<Id, Decimal>();
    Map<Id, Decimal> bomSiteAssetOrderMap = new Map<Id, Decimal>();
    Map<Id, Decimal> bomOtherOrderMap = new Map<Id, Decimal>();

    try {
      // process order data...
      for (bomWrapper ord : orderData) {
        Decimal qty = ord.OrderQuantity;

        // collate BOM Item Joins
        if (ord.sabjId != null) {
          // site assets
          if (bomSiteAssetOrderMap.containsKey(ord.sabjId))
            qty += bomSiteAssetOrderMap.get(ord.sabjId);
          bomSiteAssetOrderMap.put(ord.sabjId, qty);
        } else // take off is at the BOM level
        {
          // non-site assets (other)
          if (bomOtherOrderMap.containsKey(ord.bomItemId))
            qty += bomOtherOrderMap.get(ord.bomItemId);
          bomOtherOrderMap.put(ord.bomItemId, qty);
        }

        // collate BOM Items
        if (ord.bomItemId != null) {
          if (bomItemOrderMap.containsKey(ord.bomItemId))
            qty += bomItemOrderMap.get(ord.bomItemId);
          bomItemOrderMap.put(ord.bomItemId, qty);
        }
      }

      // find and update the site asset bom joins (Site_Asset_BOM_Join__c) records (if any)
      List<Site_Asset_BOM_Join__c> siteAssetBOMJoins = r3CreatePurchaseOrderLineItemsForBom.getSABJs(
        new List<Id>(bomSiteAssetOrderMap.keySet())
      );
      List<Site_Asset_BOM_Join__c> updateSiteAssetBOMJoins = new List<Site_Asset_BOM_Join__c>();
      for (Site_Asset_BOM_Join__c bomJoin : siteAssetBOMJoins) {
        bomJoin.Project_BOM_Item__r.Order_Request__c = materialsRequest;
        if (bomJoin.On_Order__c == null)
          bomJoin.On_Order__c = 0;
        bomJoin.On_Order__c =
          bomJoin.On_Order__c + bomSiteAssetOrderMap.get(bomJoin.Id);
        updateSiteAssetBOMJoins.add(bomJoin);
      }
      if (updateSiteAssetBOMJoins.size() > 0) {
        update updateSiteAssetBOMJoins;
      }

      // find and update BOM line items...
      List<Project_BOM_Item__c> pbis = r3CreatePurchaseOrderLineItemsForBom.getBOMs(
        new List<Id>(bomItemOrderMap.keySet())
      );
      System.debug(
        'r3ProductTakeOffController.updateBOM: pbis:sz=' + pbis.size()
      );

      for (Project_BOM_Item__c bomItem : pbis) {
        bomItem.Order_Request__c = materialsRequest;
        // KF uncomment start
        if (bomItem.Order_Qnty__c == null)
          bomItem.Order_Qnty__c = 0;
        bomItem.Order_Qnty__c = bomItemOrderMap.get(bomItem.Id);
        // KF uncomment end
        if (bomItem.On_Order_Other__c == null)
          bomItem.On_Order_Other__c = 0;
        if (bomOtherOrderMap.containsKey(bomItem.Id))
          bomItem.On_Order_Other__c =
            bomItem.On_Order_Other__c + bomOtherOrderMap.get(bomItem.Id);
        bomUpdateList.add(bomItem);
      }
      System.debug(
        'r3ProductTakeOffController.updateBOM: bomUpdateList:sz=' +
        bomUpdateList.size()
      );

      if (bomUpdateList.size() > 0) {
        update bomUpdateList;
      }

      // create purchase order line items and tasks...
      r3CreatePurchaseOrderLineItemsForBom.createProjectTasks(
        new List<Id>(bomItemOrderMap.keySet()),
        new List<Id>(bomSiteAssetOrderMap.keySet())
      );

      r3CreatePurchaseOrderLineItemsForBom.createPurchaseOrderLines(
        bomUpdateList
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }

    return JSON.serializePretty(bomUpdateList);
  }

  /*
    @AuraEnabled
    public static String getNavigationTopicsTreeData(String TopicId)
    {
        system.debug('CAS>> TopicId = '+TopicId);
        return getNavigationTopicsTreeDataWithId(Network.getNetworkId(), TopicId);
    }
    */

  @AuraEnabled
  public static Integer getBomTreeCount() {
    system.debug('CAS>> Count = ' + Count);
    return Count;
  }

  private static List<bomWrapper> getBomWrapperChildList(
    List<Product_Kit__c> pks,
    Map<id, List<Product_Kit__c>> pbiMap,
    Decimal qty
  ) {
    List<bomWrapper> bwl = new List<bomWrapper>();
    for (Product_Kit__c pk : pks) {
      bomWrapper bw = new bomWrapper();
      bw.key = String.valueof(Count++);
      if (pk.Quantity__c != null && qty != null) {
        bw.EstQty = pk.Quantity__c * qty;
      }
      //bw.OrderQuantity = 0;
      bw.LeadTime = pk.Salesforce_Product__r.Lead_Time__c;
      bw.ProductCode = pk.Salesforce_Product__r.ProductCode;
      bw.expanded = false;
      //bw.Id = pk.Salesforce_Product__c;
      bw.ProductId = null; // such that not included on order screen
      bw.ProductName = pk.Salesforce_Product__r.Name;
      bw.ProductUrl = '/' + pk.Salesforce_Product__c;
      bw.bomId = pk.Salesforce_Product__c;
      bw.ProductKit = false;

      bwl.add(bw);
    }
    return bwl;
  }

  private static Map<String, Id> getEstimateProductEstimateMap(
    List<Id> estimateProductIds
  ) {
    // Create estimateProductId to Estimate Map
    List<OpportunityLineItem__c> estimateProducts = [
      SELECT Id, OpportunityId__c, Product2Id__c
      FROM OpportunityLineItem__c
      WHERE Id IN :estimateProductIds
    ];
    Map<String, Id> estimateProductEstimateMap = new Map<String, Id>();
    for (OpportunityLineItem__c estimateProduct : estimateProducts) {
      estimateProductEstimateMap.put(
        estimateProduct.Id,
        estimateProduct.OpportunityId__c
      );
    }
    return estimateProductEstimateMap;
  }

  public class bomWrapper {
    /*@AuraEnabled
     public id Id {get;set;}*/
    @AuraEnabled
    public id estimateId { get; set; }
    @AuraEnabled
    public id sabjId { get; set; }
    @AuraEnabled
    public id bomId { get; set; }
    @AuraEnabled
    public id bomItemId { get; set; }
    @AuraEnabled
    public String Key { get; set; }
    @AuraEnabled
    public id ProductId { get; set; }
    @AuraEnabled
    public String ProductName { get; set; }
    @AuraEnabled
    public String Address { get; set; }
    @AuraEnabled
    public String ProductUrl { get; set; }
    @AuraEnabled
    public String LeadTime { get; set; }
    @AuraEnabled
    public String ProductCode { get; set; }
    @AuraEnabled
    public Boolean ProductKit { get; set; }
    @AuraEnabled
    public Decimal OrderQuantity { get; set; }
    @AuraEnabled
    public Decimal TakeOff { get; set; }
    @AuraEnabled
    public Decimal EstQty { get; set; }
    @AuraEnabled
    public String PlotName { get; set; }
    @AuraEnabled
    public List<bomWrapper> items { get; set; }
    @AuraEnabled
    public Boolean expanded { get; set; }

    public bomWrapper(Id bomiId, Integer num, String name, Id recordid) {
      bomItemId = bomiId;
      key = String.valueof(num);
      ProductName = name;
      ProductUrl = '/' + recordid;
      ProductCode = '';
      ProductKit = false;
      items = new List<bomWrapper>();
      expanded = true;
    }

    public bomWrapper(
      Id bomiId,
      Integer num,
      String name,
      Id recordid,
      String add
    ) {
      bomItemId = bomiId;
      key = String.valueof(num);
      ProductName = name;
      ProductUrl = '/' + recordid;
      Address = add;
      ProductCode = '';
      ProductKit = false;
      items = new List<bomWrapper>();
      expanded = true;
    }

    // Product Kit-Site Asset Level wrapper/ Product Wrapper
    public bomWrapper(
      Id saBJoinId,
      Id bomiId,
      Integer num,
      String name,
      Id recordid,
      Decimal est_qty,
      String pcode,
      String ltime,
      Decimal OrderQty,
      Id pid,
      String pltname
    ) {
      sabjId = saBJoinId;
      bomItemId = bomiId;
      key = String.valueof(num);
      ProductName = name;
      ProductUrl = '/' + saBJoinId;
      EstQty = est_qty;
      ProductCode = pcode;
      ProductId = pid;
      LeadTime = ltime;
      PlotName = pltname;
      OrderQuantity = OrderQty;
      ProductKit = true;
      items = new List<bomWrapper>();
      expanded = true;
    }

    // Product Kit-BOM Item Wrapper(Other)  / Product Wrapper
    public bomWrapper(
      Id bomiId,
      Integer num,
      String name,
      Id recordid,
      Decimal est_qty,
      String pcode,
      String ltime,
      Decimal OrderQty,
      Id pid,
      String pltname
    ) {
      bomItemId = bomiId;
      key = String.valueof(num);
      ProductName = name;
      ProductUrl = '/' + recordid;
      EstQty = est_qty;
      ProductCode = pcode;
      ProductId = pid;
      LeadTime = ltime;
      PlotName = pltname;
      OrderQuantity = OrderQty;
      ProductKit = true;
      items = new List<bomWrapper>();
      expanded = true;
    }

    public bomWrapper() {
    }
  }
}