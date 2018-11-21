require 'activefacts/api'

module ::Warehousing

  class BinID < AutoCounter
    value_type 
    one_to_one :bin                             # See Bin.bin_id
  end

  class DispatchID < AutoCounter
    value_type 
    one_to_one :dispatch                        # See Dispatch.dispatch_id
  end

  class DispatchItemID < AutoCounter
    value_type 
    one_to_one :dispatch_item                   # See DispatchItem.dispatch_item_id
  end

  class PartyID < AutoCounter
    value_type 
    one_to_one :party                           # See Party.party_id
  end

  class ProductID < AutoCounter
    value_type 
    one_to_one :product                         # See Product.product_id
  end

  class PurchaseOrderID < AutoCounter
    value_type 
    one_to_one :purchase_order                  # See PurchaseOrder.purchase_order_id
  end

  class Quantity < UnsignedInteger
    value_type :length => 32
  end

  class ReceiptID < AutoCounter
    value_type 
    one_to_one :receipt                         # See Receipt.receipt_id
  end

  class ReceivedItemID < AutoCounter
    value_type 
    one_to_one :received_item                   # See ReceivedItem.received_item_id
  end

  class SalesOrderID < AutoCounter
    value_type 
    one_to_one :sales_order                     # See SalesOrder.sales_order_id
  end

  class TransferRequestID < AutoCounter
    value_type 
    one_to_one :transfer_request                # See TransferRequest.transfer_request_id
  end

  class WarehouseID < AutoCounter
    value_type 
    one_to_one :warehouse                       # See Warehouse.warehouse_id
  end

  class Bin
    identified_by :bin_id
    one_to_one :bin_id, :class => BinID, :mandatory => true  # See BinID.bin
    has_one :product                            # See Product.all_bin
    has_one :quantity, :mandatory => true       # See Quantity.all_bin
    has_one :warehouse                          # See Warehouse.all_bin
  end

  class Dispatch
    identified_by :dispatch_id
    one_to_one :dispatch_id, :class => DispatchID, :mandatory => true  # See DispatchID.dispatch
  end

  class DispatchItem
    identified_by :dispatch_item_id
    has_one :dispatch, :mandatory => true       # See Dispatch.all_dispatch_item
    one_to_one :dispatch_item_id, :class => DispatchItemID, :mandatory => true  # See DispatchItemID.dispatch_item
    has_one :product, :mandatory => true        # See Product.all_dispatch_item
    has_one :quantity, :mandatory => true       # See Quantity.all_dispatch_item
    has_one :sales_order_item                   # See SalesOrderItem.all_dispatch_item
    has_one :transfer_request                   # See TransferRequest.all_dispatch_item
  end

  class Party
    identified_by :party_id
    one_to_one :party_id, :class => PartyID, :mandatory => true  # See PartyID.party
  end

  class Product
    identified_by :product_id
    one_to_one :product_id, :class => ProductID, :mandatory => true  # See ProductID.product
  end

  class PurchaseOrder
    identified_by :purchase_order_id
    one_to_one :purchase_order_id, :class => PurchaseOrderID, :mandatory => true  # See PurchaseOrderID.purchase_order
    has_one :supplier, :mandatory => true       # See Supplier.all_purchase_order
    has_one :warehouse, :mandatory => true      # See Warehouse.all_purchase_order
  end

  class PurchaseOrderItem
    identified_by :purchase_order, :product
    has_one :product, :mandatory => true        # See Product.all_purchase_order_item
    has_one :purchase_order, :mandatory => true  # See PurchaseOrder.all_purchase_order_item
    has_one :quantity, :mandatory => true       # See Quantity.all_purchase_order_item
  end

  class Receipt
    identified_by :receipt_id
    one_to_one :receipt_id, :class => ReceiptID, :mandatory => true  # See ReceiptID.receipt
  end

  class ReceivedItem
    identified_by :received_item_id
    has_one :product, :mandatory => true        # See Product.all_received_item
    has_one :purchase_order_item                # See PurchaseOrderItem.all_received_item
    has_one :quantity, :mandatory => true       # See Quantity.all_received_item
    has_one :receipt, :mandatory => true        # See Receipt.all_received_item
    one_to_one :received_item_id, :class => ReceivedItemID, :mandatory => true  # See ReceivedItemID.received_item
    has_one :transfer_request                   # See TransferRequest.all_received_item
  end

  class SalesOrder
    identified_by :sales_order_id
    has_one :customer, :mandatory => true       # See Customer.all_sales_order
    one_to_one :sales_order_id, :class => SalesOrderID, :mandatory => true  # See SalesOrderID.sales_order
    has_one :warehouse, :mandatory => true      # See Warehouse.all_sales_order
  end

  class SalesOrderItem
    identified_by :sales_order, :product
    has_one :product, :mandatory => true        # See Product.all_sales_order_item
    has_one :quantity, :mandatory => true       # See Quantity.all_sales_order_item
    has_one :sales_order, :mandatory => true    # See SalesOrder.all_sales_order_item
  end

  class Supplier < Party
  end

  class TransferRequest
    identified_by :transfer_request_id
    has_one :from_warehouse, :class => "Warehouse", :mandatory => true  # See Warehouse.all_transfer_request_as_from_warehouse
    has_one :product, :mandatory => true        # See Product.all_transfer_request
    has_one :quantity, :mandatory => true       # See Quantity.all_transfer_request
    has_one :to_warehouse, :class => "Warehouse", :mandatory => true  # See Warehouse.all_transfer_request_as_to_warehouse
    one_to_one :transfer_request_id, :class => TransferRequestID, :mandatory => true  # See TransferRequestID.transfer_request
  end

  class Warehouse
    identified_by :warehouse_id
    one_to_one :warehouse_id, :class => WarehouseID, :mandatory => true  # See WarehouseID.warehouse
  end

  class BackOrderAllocation
    identified_by :purchase_order_item, :sales_order_item
    has_one :purchase_order_item, :mandatory => true  # See PurchaseOrderItem.all_back_order_allocation
    has_one :sales_order_item, :mandatory => true  # See SalesOrderItem.all_back_order_allocation
    has_one :quantity, :mandatory => true       # See Quantity.all_back_order_allocation
  end

  class Customer < Party
  end

end
