<template>
  <div class="coming-soon">
    <div class="coming-soon-content">
      <div class="icon-container">
        <el-icon size="80" color="#409EFF">
          <Tools />
        </el-icon>
      </div>
      
      <h1 class="title">Đang Phát Triển</h1>
      <p class="description">
        Tính năng này đang được xây dựng và sẽ sớm có mặt trong phiên bản tiếp theo.
      </p>
      
      <div class="feature-info">
        <h3>Tính năng sẽ có:</h3>
        <ul class="feature-list">
          <li v-for="feature in features" :key="feature">
            <el-icon color="#67C23A"><Check /></el-icon>
            {{ feature }}
          </li>
        </ul>
      </div>
      
      <div class="actions">
        <el-button type="primary" @click="goBack">
          <el-icon><ArrowLeft /></el-icon>
          Quay lại
        </el-button>
        <el-button @click="goHome">
          <el-icon><House /></el-icon>
          Về trang chủ
        </el-button>
      </div>
      
      <div class="progress-info">
        <p class="progress-text">Tiến độ phát triển:</p>
        <el-progress
          :percentage="progressPercentage"
          :color="progressColor"
          :stroke-width="8"
        />
        <p class="eta">Dự kiến hoàn thành: {{ eta }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Tools, Check, ArrowLeft, House } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()

// Dynamic content based on route
const getFeaturesByRoute = (routeName: string) => {
  const featureMap: Record<string, string[]> = {
    'warehouses': [
      'Quản lý thông tin kho',
      'Cấu hình capacity và zones',
      'Phân quyền quản lý kho',
      'Báo cáo hiệu suất kho'
    ],
    'warehouse-zones': [
      'Thiết lập khu vực kho',
      'Quản lý nhiệt độ và độ ẩm',
      'Phân loại theo mục đích sử dụng',
      'Tối ưu hóa layout'
    ],
    'storage-locations': [
      'Quản lý vị trí lưu trữ chi tiết',
      'Mã vạch cho từng vị trí',
      'Theo dõi capacity từng vị trí',
      'Tối ưu hóa picking routes'
    ],
    'sales-orders': [
      'Quản lý đơn hàng bán',
      'Tự động allocation',
      'Theo dõi trạng thái giao hàng',
      'Tích hợp với CRM'
    ],
    'purchase-orders': [
      'Quản lý đơn đặt hàng',
      'Workflow phê duyệt',
      'Theo dõi lead time',
      'Tích hợp với suppliers'
    ],
    'quality-standards': [
      'Thiết lập tiêu chuẩn chất lượng',
      'Quy trình inspection',
      'Sampling methods',
      'Quality reports'
    ],
    'abc-analysis': [
      'Phân tích ABC tự động',
      'Phân loại sản phẩm theo giá trị',
      'Báo cáo xu hướng',
      'Khuyến nghị tối ưu'
    ],
    'cost-centers': [
      'Quản lý trung tâm chi phí',
      'Phân bổ chi phí theo hoạt động',
      'Budget tracking',
      'Cost analysis reports'
    ],
    'api-integrations': [
      'Tích hợp API với hệ thống khác',
      'Webhook management',
      'Real-time synchronization',
      'API monitoring'
    ],
    'mobile-devices': [
      'Quản lý thiết bị di động',
      'Mobile app deployment',
      'Device tracking',
      'Remote configuration'
    ]
  }
  
  return featureMap[routeName] || [
    'Giao diện người dùng hiện đại',
    'Tích hợp với hệ thống hiện tại',
    'Báo cáo và analytics',
    'Mobile responsive'
  ]
}

const getProgressByRoute = (routeName: string) => {
  const progressMap: Record<string, number> = {
    'warehouses': 25,
    'warehouse-zones': 15,
    'storage-locations': 30,
    'sales-orders': 40,
    'purchase-orders': 35,
    'quality-standards': 20,
    'abc-analysis': 50,
    'cost-centers': 25,
    'api-integrations': 60,
    'mobile-devices': 45
  }
  
  return progressMap[routeName] || 30
}

const getEtaByRoute = (routeName: string) => {
  const etaMap: Record<string, string> = {
    'warehouses': 'Q1 2025',
    'warehouse-zones': 'Q2 2025',
    'storage-locations': 'Q1 2025',
    'sales-orders': 'Q1 2025',
    'purchase-orders': 'Q1 2025',
    'quality-standards': 'Q2 2025',
    'abc-analysis': 'Q1 2025',
    'cost-centers': 'Q2 2025',
    'api-integrations': 'Q1 2025',
    'mobile-devices': 'Q1 2025'
  }
  
  return etaMap[routeName] || 'Q1 2025'
}

const features = computed(() => getFeaturesByRoute(route.name as string))
const progressPercentage = computed(() => getProgressByRoute(route.name as string))
const eta = computed(() => getEtaByRoute(route.name as string))

const progressColor = computed(() => {
  if (progressPercentage.value >= 50) return '#67C23A'
  if (progressPercentage.value >= 25) return '#E6A23C'
  return '#F56C6C'
})

const goBack = () => {
  router.go(-1)
}

const goHome = () => {
  router.push('/')
}
</script>

<style scoped>
.coming-soon {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  padding: 20px;
}

.coming-soon-content {
  max-width: 600px;
  text-align: center;
  background: white;
  border-radius: 20px;
  padding: 60px 40px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
}

.icon-container {
  margin-bottom: 30px;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-10px);
  }
  60% {
    transform: translateY(-5px);
  }
}

.title {
  font-size: 36px;
  font-weight: 700;
  color: #303133;
  margin: 0 0 16px 0;
}

.description {
  font-size: 18px;
  color: #606266;
  margin: 0 0 40px 0;
  line-height: 1.6;
}

.feature-info {
  text-align: left;
  margin-bottom: 40px;
  padding: 24px;
  background: #f8f9fa;
  border-radius: 12px;
}

.feature-info h3 {
  margin: 0 0 20px 0;
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  text-align: center;
}

.feature-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.feature-list li {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
  font-size: 15px;
  color: #606266;
}

.actions {
  display: flex;
  gap: 16px;
  justify-content: center;
  margin-bottom: 40px;
}

.progress-info {
  border-top: 1px solid #e4e7ed;
  padding-top: 24px;
}

.progress-text {
  font-size: 14px;
  color: #909399;
  margin: 0 0 12px 0;
  font-weight: 500;
}

.eta {
  font-size: 13px;
  color: #909399;
  margin: 12px 0 0 0;
}

/* Responsive Design */
@media (max-width: 768px) {
  .coming-soon-content {
    padding: 40px 24px;
    margin: 0 12px;
  }
  
  .title {
    font-size: 28px;
  }
  
  .description {
    font-size: 16px;
  }
  
  .actions {
    flex-direction: column;
    align-items: center;
  }
  
  .actions .el-button {
    min-width: 160px;
  }
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
  .coming-soon {
    background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  }
  
  .coming-soon-content {
    background: #1e1e1e;
    color: #e4e7ed;
  }
  
  .title {
    color: #e4e7ed;
  }
  
  .feature-info {
    background: #2a2a2a;
  }
}
</style>