object frameUart: TframeUart
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  BiDiMode = bdLeftToRight
  ParentBiDiMode = False
  TabOrder = 0
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 451
    Height = 19
    AutoSize = True
    ButtonHeight = 19
    ButtonWidth = 60
    Caption = 'ToolBar'
    DrawingStyle = dsGradient
    List = True
    AllowTextButtons = True
    TabOrder = 0
    Transparent = True
    object cbbComPort: TComboBox
      Left = 0
      Top = 0
      Width = 89
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'COM1'
      Items.Strings = (
        'COM1'
        'COM2'
        'COM3'
        'COM4')
    end
    object ToolButton1: TToolButton
      Left = 89
      Top = 0
      Action = actPortOpenClose
      Style = tbsTextButton
    end
    object tbUartRefresh: TToolButton
      Left = 148
      Top = 0
      Action = actRefreshPort1
      Style = tbsTextButton
    end
    object tblUartParam: TToolButton
      Left = 207
      Top = 0
      Action = actSetupUart
      Style = tbsTextButton
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 285
    Width = 451
    Height = 19
    Panels = <
      item
        Width = 170
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object ActionList: TActionList
    Left = 128
    Top = 40
    object actRefreshPort1: TAction
      Caption = #21047#26032#20018#21475
      OnExecute = actRefreshPort1Execute
    end
    object actSetupUart: TAction
      Caption = #20018#21475#21442#25968
      OnExecute = actSetupUartExecute
      OnUpdate = actSetupUartUpdate
    end
    object actPortOpenClose: TAction
      Caption = #20018#21475#24320#20851
      OnExecute = actPortOpenCloseExecute
      OnUpdate = actPortOpenCloseUpdate
    end
  end
end
