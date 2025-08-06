<template>
  <div class="common-layout">
    <el-container>
      <el-aside :width="isCollapsed ? '64px' : '220px'" class="sidebar-container">
        <Sidebar :is-collapsed="isCollapsed" />
      </el-aside>
      <el-container>
        <el-header class="main-header">
          <div class="header-left">
            <el-icon class="collapse-icon" @click="toggleCollapse">
              <component :is="isCollapsed ? 'Expand' : 'Fold'" />
            </el-icon>
          </div>
          <div class="header-right">
            <span>Welcome, Admin!</span>
            <el-dropdown>
              <el-avatar src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item>Profile</el-dropdown-item>
                  <el-dropdown-item>Settings</el-dropdown-item>
                  <el-dropdown-item divided>Logout</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </el-header>
        <el-main class="main-content">
          <RouterView />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { RouterView } from 'vue-router'
import Sidebar from './components/Sidebar.vue'
import { Fold, Expand } from '@element-plus/icons-vue'

const isCollapsed = ref(false)

const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value
}
</script>

<style>
/* Global styles */
body {
  margin: 0;
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB',
    'Microsoft YaHei', '微软雅黑', Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.common-layout {
  height: 100vh;
}

.el-container {
  height: 100%;
}

.sidebar-container {
  transition: width 0.28s;
  background-color: #304156;
}

.main-header {
  background-color: #fff;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
}

.header-left, .header-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.collapse-icon {
  font-size: 24px;
  cursor: pointer;
}

.main-content {
  background-color: #f0f2f5;
  padding: 20px;
}
</style>
