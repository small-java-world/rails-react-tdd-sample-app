import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom'
import UserPreferences from './UserPreferences'

describe('UserPreferences', () => {
  beforeEach(() => {
    // 【テスト前準備】: 各テスト実行前にlocalStorageとDOM状態を初期化し、一貫したテスト条件を保証
    // 【環境初期化】: 前のテストの影響を受けないよう、ブラウザストレージとDOM属性をクリーンにリセット
    localStorage.clear()
    document.documentElement.removeAttribute('data-theme')
    document.body.className = ''
  })

  afterEach(() => {
    // 【テスト後処理】: テスト実行後に設定された属性やクラスを削除し、次のテストに影響しないようにする
    // 【状態復元】: DOM状態を元に戻し、localStorageもクリアして初期状態に復元
    localStorage.clear()
    document.documentElement.removeAttribute('data-theme')
    document.body.className = ''
  })

  test('3つの設定選択UI要素が表示される', () => {
    // 【テスト目的】: UserPreferencesコンポーネントが3つの必須設定項目を正しく表示することを確認
    // 【テスト内容】: Theme、Refresh Interval、Display Densityの3つのselect要素の存在を検証
    // 【期待される動作】: 各設定項目のselect要素が画面に表示され、適切なラベルが設定されている
    // 🟢 信頼性レベル: 要件REQ-001に明確に記載されている必須機能

    // 【コンポーネント描画】: UserPreferencesコンポーネントを描画してテスト対象とする
    // 【初期状態確認】: 未実装状態でのコンポーネント構造を検証
    render(<UserPreferences />)

    // 【結果検証】: 各設定項目のselect要素が存在することを確認
    // 【期待値確認】: テーマ選択のselect要素が存在し、適切なaria-labelが設定されている
    expect(screen.getByLabelText('Theme')).toBeInTheDocument() // 【確認内容】: テーマ選択のselect要素が存在することを確認 🟢
    
    // 【期待値確認】: 自動更新間隔選択のselect要素が存在し、適切なaria-labelが設定されている
    expect(screen.getByLabelText('Refresh Interval')).toBeInTheDocument() // 【確認内容】: 自動更新間隔選択のselect要素が存在することを確認 🟢
    
    // 【期待値確認】: 表示密度選択のselect要素が存在し、適切なaria-labelが設定されている
    expect(screen.getByLabelText('Display Density')).toBeInTheDocument() // 【確認内容】: 表示密度選択のselect要素が存在することを確認 🟢
  })

  test('テーマ選択に正しい選択肢とデフォルト値が設定される', () => {
    // 【テスト目的】: テーマ選択のselect要素に仕様通りの選択肢と初期値が設定されることを確認
    // 【テスト内容】: light/darkオプションの存在とデフォルト値「light」の選択状態を検証
    // 【期待される動作】: テーマ選択でlightが初期選択され、light/dark両方のオプションが利用可能
    // 🟢 信頼性レベル: 要件REQ-101, REQ-102で明確に規定されている選択肢とデフォルト値

    // 【コンポーネント描画】: UserPreferencesコンポーネントを描画してテーマ選択部分をテスト
    render(<UserPreferences />)

    // 【テーマ選択要素取得】: aria-labelを使用してテーマ選択のselect要素を特定
    const themeSelect = screen.getByLabelText('Theme')

    // 【結果検証】: テーマ選択の選択肢と初期値を確認
    // 【期待値確認】: デフォルト値がlightに設定されていることを確認
    expect(themeSelect).toHaveValue('light') // 【確認内容】: テーマのデフォルト値がlightであることを確認 🟢
    
    // 【期待値確認】: lightオプションが存在し選択可能であることを確認
    expect(screen.getByRole('option', { name: 'Light' })).toBeInTheDocument() // 【確認内容】: lightオプションの存在を確認 🟢
    
    // 【期待値確認】: darkオプションが存在し選択可能であることを確認
    expect(screen.getByRole('option', { name: 'Dark' })).toBeInTheDocument() // 【確認内容】: darkオプションの存在を確認 🟢
  })

  test('自動更新間隔選択に正しい選択肢とデフォルト値が設定される', () => {
    // 【テスト目的】: 自動更新間隔選択のselect要素に仕様通りの選択肢と初期値が設定されることを確認
    // 【テスト内容】: Off/5/10/30秒オプションの存在とデフォルト値「Off」の選択状態を検証
    // 【期待される動作】: 自動更新間隔でOffが初期選択され、全ての時間選択肢が利用可能
    // 🟢 信頼性レベル: 要件REQ-103, REQ-104で明確に規定されている選択肢とデフォルト値

    // 【コンポーネント描画】: UserPreferencesコンポーネントを描画して自動更新間隔選択部分をテスト
    render(<UserPreferences />)

    // 【更新間隔選択要素取得】: aria-labelを使用して自動更新間隔選択のselect要素を特定
    const intervalSelect = screen.getByLabelText('Refresh Interval')

    // 【結果検証】: 自動更新間隔選択の選択肢と初期値を確認
    // 【期待値確認】: デフォルト値がOffに設定されていることを確認
    expect(intervalSelect).toHaveValue('Off') // 【確認内容】: 自動更新間隔のデフォルト値がOffであることを確認 🟢
    
    // 【期待値確認】: Offオプションが存在し選択可能であることを確認
    expect(screen.getByRole('option', { name: 'Off' })).toBeInTheDocument() // 【確認内容】: Offオプションの存在を確認 🟢
    
    // 【期待値確認】: 5秒オプションが存在し選択可能であることを確認
    expect(screen.getByRole('option', { name: '5 seconds' })).toBeInTheDocument() // 【確認内容】: 5秒オプションの存在を確認 🟢
    
    // 【期待値確認】: 10秒オプションが存在し選択可能であることを確認
    expect(screen.getByRole('option', { name: '10 seconds' })).toBeInTheDocument() // 【確認内容】: 10秒オプションの存在を確認 🟢
    
    // 【期待値確認】: 30秒オプションが存在し選択可能であることを確認
    expect(screen.getByRole('option', { name: '30 seconds' })).toBeInTheDocument() // 【確認内容】: 30秒オプションの存在を確認 🟢
  })

  test('表示密度選択に正しい選択肢とデフォルト値が設定される', () => {
    // 【テスト目的】: 表示密度選択のselect要素に仕様通りの選択肢と初期値が設定されることを確認
    // 【テスト内容】: compact/standardオプションの存在とデフォルト値「standard」の選択状態を検証
    // 【期待される動作】: 表示密度でstandardが初期選択され、compact/standard両方のオプションが利用可能
    // 🟢 信頼性レベル: 要件REQ-105, REQ-106で明確に規定されている選択肢とデフォルト値

    // 【コンポーネント描画】: UserPreferencesコンポーネントを描画して表示密度選択部分をテスト
    render(<UserPreferences />)

    // 【密度選択要素取得】: aria-labelを使用して表示密度選択のselect要素を特定
    const densitySelect = screen.getByLabelText('Display Density')

    // 【結果検証】: 表示密度選択の選択肢と初期値を確認
    // 【期待値確認】: デフォルト値がstandardに設定されていることを確認
    expect(densitySelect).toHaveValue('standard') // 【確認内容】: 表示密度のデフォルト値がstandardであることを確認 🟢
    
    // 【期待値確認】: compactオプションが存在し選択可能であることを確認
    expect(screen.getByRole('option', { name: 'Compact' })).toBeInTheDocument() // 【確認内容】: compactオプションの存在を確認 🟢
    
    // 【期待値確認】: standardオプションが存在し選択可能であることを確認
    expect(screen.getByRole('option', { name: 'Standard' })).toBeInTheDocument() // 【確認内容】: standardオプションの存在を確認 🟢
  })

  test('各設定選択要素が適切なアクセシビリティ属性を持つ', () => {
    // 【テスト目的】: 全ての設定選択要素が適切なアクセシビリティ属性を持つことを確認
    // 【テスト内容】: aria-label属性の設定とスクリーンリーダー対応の検証
    // 【期待される動作】: 各select要素に適切なaria-labelが設定され、アクセシブルな実装となっている
    // 🟢 信頼性レベル: UI/UX要件でアクセシビリティ対応が明確に規定されている

    // 【コンポーネント描画】: UserPreferencesコンポーネントを描画してアクセシビリティ属性をテスト
    render(<UserPreferences />)

    // 【結果検証】: 各設定選択要素のアクセシビリティ属性を確認
    // 【期待値確認】: テーマ選択にaria-label属性が設定されている
    expect(screen.getByLabelText('Theme')).toHaveAttribute('aria-label', 'Theme') // 【確認内容】: テーマ選択のaria-label属性を確認 🟢
    
    // 【期待値確認】: 自動更新間隔選択にaria-label属性が設定されている
    expect(screen.getByLabelText('Refresh Interval')).toHaveAttribute('aria-label', 'Refresh Interval') // 【確認内容】: 自動更新間隔選択のaria-label属性を確認 🟢
    
    // 【期待値確認】: 表示密度選択にaria-label属性が設定されている
    expect(screen.getByLabelText('Display Density')).toHaveAttribute('aria-label', 'Display Density') // 【確認内容】: 表示密度選択のaria-label属性を確認 🟢
  })

  test('各設定選択時にonChangeイベントが正常に動作する', async () => {
    // 【テスト目的】: 各設定選択要素のonChangeイベントが正常に動作することを確認
    // 【テスト内容】: ユーザーの選択操作に対して適切にイベントが発火し、値が更新されることを検証
    // 【期待される動作】: 各select要素で選択を変更すると、即座に新しい値が反映される
    // 🟡 信頼性レベル: UI操作の基本動作として推測される要件（明確な記述はないが妥当な推測）

    // 【ユーザーイベント準備】: ユーザー操作をシミュレートするためのセットアップ
    const user = userEvent.setup()

    // 【コンポーネント描画】: UserPreferencesコンポーネントを描画してイベント動作をテスト
    render(<UserPreferences />)

    // 【各選択要素取得】: テスト対象のselect要素を取得
    const themeSelect = screen.getByLabelText('Theme')
    const intervalSelect = screen.getByLabelText('Refresh Interval')
    const densitySelect = screen.getByLabelText('Display Density')

    // 【実際の処理実行】: ユーザー操作による値変更をシミュレート
    // 【処理内容】: テーマをdarkに変更し、値が正しく更新されることを確認
    await user.selectOptions(themeSelect, 'dark')
    expect(themeSelect).toHaveValue('dark') // 【確認内容】: テーマ変更時に値が正しく更新されることを確認 🟡

    // 【処理内容】: 自動更新間隔を10秒に変更し、値が正しく更新されることを確認
    await user.selectOptions(intervalSelect, '10')
    expect(intervalSelect).toHaveValue('10') // 【確認内容】: 更新間隔変更時に値が正しく更新されることを確認 🟡

    // 【処理内容】: 表示密度をcompactに変更し、値が正しく更新されることを確認
    await user.selectOptions(densitySelect, 'compact')
    expect(densitySelect).toHaveValue('compact') // 【確認内容】: 密度変更時に値が正しく更新されることを確認 🟡
  })
})