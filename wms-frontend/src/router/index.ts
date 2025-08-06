import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    // Dashboard
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },

        // Inventory Management (Existing files)
    {
      path: '/inventory/overview',
      name: 'inventory-overview',
      component: () => import('../views/InventoryOverview.vue'),
    },
    {
      path: '/inventory/transactions',
      name: 'inventory-transactions',
      component: () => import('../views/WarehouseTransactions.vue'),
    },
    {
      path: '/inventory/inbound',
      name: 'inventory-inbound',
      component: () => import('../views/InventoryView.vue'),
    },
    {
      path: '/inventory/outbound',
      name: 'inventory-outbound',
      component: () => import('../views/InventoryView.vue'),
    },
    {
      path: '/inventory/transfer',
      name: 'inventory-transfer',
      component: () => import('../views/InventoryView.vue'),
    },

    // Product Management (Existing files)
    {
      path: '/products/list',
      name: 'product-list',
      component: () => import('../views/ProductsView.vue'),
    },
    {
      path: '/products/categories',
      name: 'product-categories',
      component: () => import('../views/ProductCategoriesView.vue'),
    },
    {
      path: '/products/units',
      name: 'product-units',
      component: () => import('../views/UnitsView.vue'),
    },

    // Picking & Shipping (Existing files)
    {
      path: '/picking/tasks',
      name: 'picking-tasks',
      component: () => import('../views/PickingTasksView.vue'),
    },

    // Partners (Existing files)
    {
      path: '/suppliers',
      name: 'suppliers',
      component: () => import('../views/SuppliersView.vue'),
    },
    {
      path: '/customers',
      name: 'customers',
      component: () => import('../views/CustomersView.vue'),
    },

    // Analytics & Reports (Existing files)
    {
      path: '/analytics/kpi',
      name: 'kpi-dashboard',
      component: () => import('../views/KPIDashboard.vue'),
    },

    // System Settings (Existing files)
    {
      path: '/system/settings',
      name: 'system-settings',
      component: () => import('../views/SettingsView.vue'),
    },

    // Warehouse Management (New files)
    {
      path: '/warehouses',
      name: 'warehouses',
      component: () => import('../views/WarehousesView.vue'),
    },
    {
      path: '/warehouse-zones',
      name: 'warehouse-zones',
      component: () => import('../views/WarehouseZonesView.vue'),
    },
    {
      path: '/storage-locations',
      name: 'storage-locations',
      component: () => import('../views/ComingSoon.vue'),
    },
    {
      path: '/orders/sales',
      name: 'sales-orders',
      component: () => import('../views/SalesOrdersView.vue'),
    },
    {
      path: '/orders/purchase',
      name: 'purchase-orders',
      component: () => import('../views/PurchaseOrdersView.vue'),
    },
    {
      path: '/orders/allocations',
      name: 'order-allocations',
      component: () => import('../views/OrderAllocationsView.vue'),
    },
    {
      path: '/quality/standards',
      name: 'quality-standards',
      component: () => import('../views/ComingSoon.vue'),
    },
    {
      path: '/analytics/abc',
      name: 'abc-analysis',
      component: () => import('../views/ABCAnalysis.vue'),
    },
    {
      path: '/analytics/forecasting',
      name: 'demand-forecasting',
      component: () => import('../views/DemandForecasting.vue'),
    },
    {
      path: '/costs/centers',
      name: 'cost-centers',
      component: () => import('../views/ComingSoon.vue'),
    },
    {
      path: '/integration/api',
      name: 'api-integrations',
      component: () => import('../views/ComingSoon.vue'),
    },
    {
      path: '/mobile/devices',
      name: 'mobile-devices',
      component: () => import('../views/ComingSoon.vue'),
    },

    // Legacy routes for compatibility
    {
      path: '/reports',
      name: 'reports',
      redirect: '/reports/inventory',
    },
    {
      path: '/settings',
      name: 'settings',
      redirect: '/system/settings',
    },
  ],
})

export default router
