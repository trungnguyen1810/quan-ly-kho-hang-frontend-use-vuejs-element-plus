import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface Warehouse {
  id: number
  code: string
  name: string
  address?: string
  phone?: string
  managerId?: number
  totalCapacity: number
  usedCapacity: number
  capacityUnit: string
  isActive: boolean
  createdAt: Date
  updatedAt: Date
}

export interface InventoryItem {
  id: number
  sku: string
  name: string
  categoryName: string
  warehouseName: string
  availableQuantity: number
  reservedQuantity: number
  unit: string
  averageCost: number
  totalValue: number
  stockStatus: 'good' | 'low' | 'out' | 'over'
  minStockLevel: number
  maxStockLevel: number
  lastMovementDate: Date
}

export interface Transaction {
  id: number
  transactionCode: string
  transactionType: 'inbound' | 'outbound' | 'transfer' | 'adjustment' | 'cycle_count'
  warehouseName: string
  partnerType?: 'supplier' | 'customer' | 'warehouse'
  partnerName?: string
  referenceCode?: string
  transactionDate: Date
  status: 'draft' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled'
  totalItems: number
  totalValue?: number
  createdBy: string
  processedBy?: string
  notes?: string
  items?: TransactionItem[]
}

export interface TransactionItem {
  productSku: string
  productName: string
  batchNumber?: string
  location?: string
  plannedQuantity: number
  actualQuantity?: number
  unit: string
  unitCost: number
  totalCost: number
}

export const useWarehouseStore = defineStore('warehouse', () => {
  // State
  const warehouses = ref<Warehouse[]>([
    {
      id: 1,
      code: 'WH-HN01',
      name: 'Kho Hà Nội - Cầu Giấy',
      address: 'Số 123 Phố Cầu Giấy, Quận Cầu Giấy, Hà Nội',
      phone: '024-3123-4567',
      totalCapacity: 4380,
      usedCapacity: 3420,
      capacityUnit: 'm³',
      isActive: true,
      createdAt: new Date('2024-01-15'),
      updatedAt: new Date('2024-12-15')
    },
    {
      id: 2,
      code: 'WH-HCM01',
      name: 'Kho TP.HCM - Quận 7',
      address: 'Số 456 Đường Nguyễn Thị Thập, Quận 7, TP.HCM',
      phone: '028-3789-0123',
      totalCapacity: 3650,
      usedCapacity: 2890,
      capacityUnit: 'm³',
      isActive: true,
      createdAt: new Date('2024-02-20'),
      updatedAt: new Date('2024-12-15')
    },
    {
      id: 3,
      code: 'WH-DN01',
      name: 'Kho Đà Nẵng - Hải Châu',
      address: 'Số 789 Đường Hải Phòng, Quận Hải Châu, Đà Nẵng',
      phone: '0236-3456-789',
      totalCapacity: 2100,
      usedCapacity: 1680,
      capacityUnit: 'm³',
      isActive: true,
      createdAt: new Date('2024-03-10'),
      updatedAt: new Date('2024-12-15')
    }
  ])

  const selectedWarehouse = ref<number | null>(null)

  // Getters
  const activeWarehouses = computed(() =>
    warehouses.value.filter(w => w.isActive)
  )

  const currentWarehouse = computed(() =>
    selectedWarehouse.value ? warehouses.value.find(w => w.id === selectedWarehouse.value) : null
  )

  const totalCapacity = computed(() =>
    activeWarehouses.value.reduce((sum, w) => sum + w.totalCapacity, 0)
  )

  const totalUsedCapacity = computed(() =>
    activeWarehouses.value.reduce((sum, w) => sum + w.usedCapacity, 0)
  )

  const overallUtilization = computed(() =>
    totalCapacity.value > 0 ? Math.round((totalUsedCapacity.value / totalCapacity.value) * 100) : 0
  )

  // Actions
  function setSelectedWarehouse(warehouseId: number | null) {
    selectedWarehouse.value = warehouseId
  }

  function addWarehouse(warehouse: Omit<Warehouse, 'id' | 'createdAt' | 'updatedAt'>) {
    const newWarehouse: Warehouse = {
      ...warehouse,
      id: Math.max(...warehouses.value.map(w => w.id)) + 1,
      createdAt: new Date(),
      updatedAt: new Date()
    }
    warehouses.value.push(newWarehouse)
    return newWarehouse
  }

  function updateWarehouse(id: number, updates: Partial<Warehouse>) {
    const index = warehouses.value.findIndex(w => w.id === id)
    if (index !== -1) {
      warehouses.value[index] = {
        ...warehouses.value[index],
        ...updates,
        updatedAt: new Date()
      }
      return warehouses.value[index]
    }
    return null
  }

  function deleteWarehouse(id: number) {
    const index = warehouses.value.findIndex(w => w.id === id)
    if (index !== -1) {
      warehouses.value.splice(index, 1)
      if (selectedWarehouse.value === id) {
        selectedWarehouse.value = null
      }
      return true
    }
    return false
  }

  function getWarehouseById(id: number) {
    return warehouses.value.find(w => w.id === id)
  }

  return {
    // State
    warehouses,
    selectedWarehouse,

    // Getters
    activeWarehouses,
    currentWarehouse,
    totalCapacity,
    totalUsedCapacity,
    overallUtilization,

    // Actions
    setSelectedWarehouse,
    addWarehouse,
    updateWarehouse,
    deleteWarehouse,
    getWarehouseById
  }
})
