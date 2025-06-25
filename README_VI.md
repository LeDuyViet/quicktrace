# 🚀 QuickTrace

[![Go Version](https://img.shields.io/badge/go-%3E%3D1.19-blue.svg)](https://golang.org/)
[![Node Version](https://img.shields.io/badge/node-%3E%3D12.0.0-green.svg)](https://nodejs.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Thư viện tracing nhẹ, nhiều màu sắc cho **Go** và **JavaScript** với màu sắc an toàn đa nền tảng và khả năng lọc thông minh.

**QuickTrace** giúp bạn debug và monitor performance một cách dễ dàng với output đẹp mắt và nhiều style khác nhau.

![QuickTrace Demo](StyleColorful.png)

*Ví dụ StyleColorful output hiển thị performance tracing với timing có mã màu*

## ✨ Tính năng

- 🎨 **Màu sắc an toàn đa nền tảng** - hoạt động tốt trên Windows, Linux, macOS
- 📊 **Nhiều style output** - Default, Colorful, Minimal, Detailed, Table, JSON
- 🔍 **Lọc thông minh** - Ẩn operations quá nhanh, hiện chỉ operations chậm, nhóm tương tự
- 📍 **Thông tin caller tự động** - Tự động capture file và line information  
- ⚡ **Zero-config** - Hoạt động ngay với cấu hình mặc định hợp lý
- 🌍 **Đa ngôn ngữ** - Hỗ trợ Go và JavaScript

## 📦 Cài đặt

### Go
```bash
go get github.com/LeDuyViet/quicktrace/go
```

### JavaScript
```bash
npm install quicktrace-js
```

## 🚀 Bắt đầu nhanh

### Ví dụ Go
```go
//go:build ignore
// +build ignore

package main

import (
    "time"
    "github.com/LeDuyViet/quicktrace/go"
)

func main() {
    tracer := tracing.NewSimpleTracer("API Call", 
        tracing.WithOutputStyle(tracing.StyleColorful))
    
    tracer.Span("Truy vấn database")
    time.Sleep(50 * time.Millisecond)
    
    tracer.Span("Xử lý dữ liệu")
    time.Sleep(20 * time.Millisecond)
    
    tracer.Span("Gửi response")
    time.Sleep(10 * time.Millisecond)
    
    tracer.End() // Tự động in output đẹp mắt
}
```

### Ví dụ JavaScript
```javascript
const { Tracer } = require('quicktrace-js');

const tracer = new Tracer('API Call', { style: 'colorful' });

tracer.span('Truy vấn database');
await new Promise(resolve => setTimeout(resolve, 50));

tracer.span('Xử lý dữ liệu');  
await new Promise(resolve => setTimeout(resolve, 20));

tracer.span('Gửi response');
await new Promise(resolve => setTimeout(resolve, 10));

tracer.end(); // Tự động in output đẹp mắt
```

## 🎨 Các Style Output

QuickTrace hỗ trợ 6 styles khác nhau:

| Style | Mô tả | Trường hợp sử dụng | Preview |
|-------|-------|-------------------|---------|
| `StyleDefault` | Định dạng table đơn giản | Mục đích chung | - |
| `StyleColorful` | Hiện đại với Unicode borders | Development/Debug | ![Colorful Style](StyleColorful.png) |
| `StyleMinimal` | Tree view gọn gàng | CI/CD logs | ![Minimal Style](StyleMinimal.png) |
| `StyleDetailed` | Phân tích đầy đủ với thống kê | Phân tích performance | ![Detailed Style](StyleDetailed.png) |
| `StyleTable` | Định dạng table sạch sẽ | Báo cáo | ![Table Style](StyleTable.png) |
| `StyleJSON` | Output JSON có cấu trúc | Tích hợp/Parsing | ![JSON Style](StyleJSON.png) |

## ⚙️ Cấu hình nâng cao

### Go
```go
tracer := tracing.NewSimpleTracer("Thao tác phức tạp",
    // Chỉ hiện operations chậm hơn 100ms
    tracing.WithShowSlowOnly(100 * time.Millisecond),
    
    // Ẩn operations nhanh hơn 1ms
    tracing.WithHideUltraFast(1 * time.Millisecond),
    
    // Nhóm operations có duration tương tự
    tracing.WithGroupSimilar(10 * time.Millisecond),
    
    // Style output tùy chỉnh
    tracing.WithOutputStyle(tracing.StyleDetailed),
)
```

### JavaScript
```javascript
const tracer = new Tracer('Thao tác phức tạp', {
    style: 'detailed',
    showSlowOnly: 100,        // ms
    hideUltraFast: 1,         // ms  
    groupSimilar: 10,         // ms
    minTotalDuration: 50      // ms
});
```

## 🔍 Lọc thông minh

QuickTrace có các tính năng lọc thông minh:

- **Show Slow Only**: Chỉ hiển thị operations chậm hơn threshold
- **Hide Ultra Fast**: Ẩn operations quá nhanh (< 1ms)
- **Group Similar**: Nhóm operations có duration tương tự
- **Min Duration**: Chỉ print khi tổng thời gian >= threshold

## 🎯 Quy tắc màu sắc

QuickTrace sử dụng quy tắc màu sắc thông minh:

| Duration | Màu | Danh mục |
|----------|-----|----------|
| > 3s | Đỏ đậm | Rất chậm |
| 1s - 3s | Đỏ | Chậm |
| 500ms - 1s | Vàng | Trung bình-Chậm |
| 200ms - 500ms | Xanh dương sáng | Trung bình |
| 100ms - 200ms | Cyan | Bình thường |
| 50ms - 100ms | Xanh lá | Nhanh |
| 10ms - 50ms | Xanh lá sáng | Rất nhanh |
| < 10ms | Xám sáng | Siêu nhanh |

## 📊 Điều khiển Runtime

### Go
```go
// Bật/tắt tracing
tracer.SetEnabled(false)

// Silent mode (thu thập data nhưng không in)
tracer.SetSilent(true)

// Đổi style trong runtime
tracer.SetOutputStyle(tracing.StyleJSON)

// Lấy measurements theo chương trình
measurements := tracer.GetMeasurements()
totalDuration := tracer.GetTotalDuration()
```

### JavaScript
```javascript
// Bật/tắt tracing
tracer.setEnabled(false);

// Silent mode
tracer.setSilent(true);

// Đổi style trong runtime  
tracer.setOutputStyle('json');

// Lấy data theo chương trình
const measurements = tracer.getMeasurements();
const totalDuration = tracer.getTotalDuration();
```

## 🌍 Hỗ trợ ngôn ngữ

| Tính năng | Go | JavaScript |
|-----------|----|-----------| 
| Tracing cơ bản | ✅ | ✅ |
| Output màu sắc | ✅ | ✅ |
| Nhiều Styles | ✅ | ✅ |
| Lọc thông minh | ✅ | ✅ |
| Thông tin Caller | ✅ | ✅ |
| Điều khiển Runtime | ✅ | ✅ |
| Export JSON | ✅ | ✅ |

## 📁 Ví dụ

Xem thêm ví dụ trong thư mục:
- `go/examples/` - Ví dụ Go
- `js/examples/` - Ví dụ JavaScript

## 🤝 Đóng góp

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/tinh-nang-tuyet-voi`)
3. Commit thay đổi (`git commit -am 'Thêm tính năng tuyệt vời'`)
4. Push lên branch (`git push origin feature/tinh-nang-tuyet-voi`)
5. Mở Pull Request

## 📝 Giấy phép

Dự án này được cấp phép theo MIT License - xem file [LICENSE](LICENSE) để biết chi tiết.

## 🙏 Lời cảm ơn

- Lấy cảm hứng từ các công cụ development hiện đại
- Được xây dựng với tính tương thích đa nền tảng
- Phản hồi và đóng góp từ cộng đồng

---

**Được tạo với ❤️ cho các developers yêu thích công cụ tracing đẹp và hữu ích.** 