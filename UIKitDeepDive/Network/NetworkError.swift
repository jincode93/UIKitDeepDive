//
//  NetworkError.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "잘못된 URL입니다."
        case .noData: return "데이터가 없습니다."
        case .decodingError(let error): return "데이터 파싱 실패: \(error.localizedDescription)"
        case .serverError(let code): return "서버 오류 (코드: \(code))"
        case .networkError(let error): return "네트워크 오류: \(error.localizedDescription)"
        }
    }
}
