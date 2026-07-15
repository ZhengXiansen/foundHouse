# Requirements — show delete action on the right

User clarified: “我的意思是希望删除在右边显示”.

Interpretation for implementation:

- The red delete action must be displayed on the right side / trailing side of the data row or card.
- The natural gesture for a right-side trailing action is dragging the card left (physical right-to-left / left swipe) to reveal the button on the right.
- Dragging right from the closed state must not reveal a left-side delete action.
- The height/alignment fix from the previous task still applies: the red action must align with the visible row/card bounds and must not fill card margin or list spacing.
- Deletion still requires tapping the revealed button and confirming in confirmDeleteRecord.
- Update widget/integration tests, QA docs, and spec to match the corrected right-side product behavior.
