package com.leduy.quicktrace;

/**
 * Định nghĩa các style output khác nhau cho QuickTrace
 */
public enum OutputStyle {
    /**
     * Style mặc định - bảng đơn giản
     */
    DEFAULT,
    
    /**
     * Style đầy màu sắc với Unicode borders
     */
    COLORFUL,
    
    /**
     * Style tối giản - tree view compact
     */
    MINIMAL,
    
    /**
     * Style chi tiết với thống kê đầy đủ
     */
    DETAILED,
    
    /**
     * Style bảng sạch sẽ
     */
    TABLE,
    
    /**
     * Output JSON có cấu trúc
     */
    JSON
}
