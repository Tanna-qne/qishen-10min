// 3D 动画动作：木头人模型和动画来自 desk-break（https://github.com/shlomorsh/desk-break，MIT 许可，见 3d/LICENSE）
// id 是 3d/exercises.glb 里的动画名。不喜欢的动作：删掉对应的一整块 { ... } 即可。
// cat 可选：warm 热身 / neck 肩颈放松 / lower 下肢 / push 推 / pull 拉 / box 拳击 / finish 腿部冲刺
window.DESK3D_LIB = [
  // 热身
  { id:'wrist-circles', name:'手腕绕环', tag:'打字族必做', cat:['warm'], sided:'换方向',
    cues:['小臂向前平举，轻轻握拳','手腕转完整的圈','25 秒后换方向'], why:'打字和握鼠标后，手腕和前臂最需要活动。', easy:'放慢速度。' },
  { id:'loose-twist-arm-swings', name:'转体甩臂', tag:'放松腰背', cat:['warm'],
    cues:['双臂放松垂下，膝盖微屈','上身左右转，让手臂自然甩着绕到身上','像风中的毛巾一样放松'], why:'轻松唤醒脊柱的转动能力。', easy:'转的幅度小一点。' },

  // 肩颈放松
  { id:'neck-side-tilt', name:'颈部侧倾', tag:'颈部两侧', cat:['neck'],
    cues:['肩膀放松下沉','耳朵慢慢靠向肩膀，肩膀不要抬','停 3 秒，回正，换另一侧'], why:'放松颈部两侧被屏幕“定住”的肌肉。', easy:'幅度小一点。' },
  { id:'neck-rotation', name:'颈部转头', tag:'颈部灵活', cat:['neck'],
    cues:['背挺直，下巴与地面平行','慢慢转头看向肩膀后方','回正，再转向另一侧'], why:'恢复颈部左右转动的范围。', easy:'转到一半就停。' },
  { id:'neck-half-circle', name:'颈部半圈', tag:'颈部放松', cat:['neck'],
    cues:['耳朵靠向一侧肩膀','下巴从胸前滚到另一侧肩膀','只在前面画半圈，不要向后仰'], why:'温和地放松整个颈部。', easy:'放慢速度。' },
  { id:'chin-tuck', name:'收下巴', tag:'头前伸矫正', cat:['neck'],
    cues:['眼睛平视前方','头向正后方收，像做双下巴','停 2 秒再放松'], why:'纠正看屏幕时的头前伸，缓解颈部压力。', easy:'坐着做也可以。' },
  { id:'levator-stretch', name:'肩胛提肌拉伸', tag:'颈后 · 肩胛', cat:['neck'], sided:'换边',
    cues:['头转向一侧一半','鼻子向腋下方向低','感受颈后被拉开，25 秒后换边'], why:'针对肩颈最常酸痛的那条肌肉。', easy:'幅度小一点。' },
  { id:'trap-stretch', name:'斜方肌拉伸', tag:'肩颈上方', cat:['neck'], sided:'换边',
    cues:['头倒向一侧','另一侧的手向下、向外伸，像在推开地面','保持呼吸，25 秒后换边'], why:'放松肩膀上方一直紧绷的斜方肌。', easy:'手不用伸太远。' },
  { id:'scapular-squeeze', name:'夹背挺胸', tag:'肩胛 · 体态', cat:['neck'],
    cues:['手肘弯曲，贴在身体两侧','夹紧肩胛骨，打开胸口','停 3 秒再放松'], why:'把前扣的肩膀拉回原位。', easy:'夹得轻一点。' },
  { id:'goalpost-rotation', name:'门柱外旋', tag:'肩袖', cat:['neck'],
    cues:['手肘抬到肩膀高度，小臂朝前','手肘不动，小臂向上转','慢慢转回前面'], why:'活动肩袖，改善圆肩。', easy:'手肘放低一点。' },
  { id:'cross-body-stretch', name:'肩部横拉', tag:'肩后侧', cat:['neck'], sided:'换边',
    cues:['一只手臂伸直横过胸前','另一只手扣在手肘上方，把它拉近','肩膀下沉，25 秒后换手'], why:'放松肩膀后侧。', easy:'拉轻一点。' },
  { id:'posture-reset', name:'体态重置', tag:'告别驼背', cat:['neck'],
    cues:['先故意像对着电脑一样驼背、头前伸','再站高，收下巴，肩膀向后拉','在最高处停 3 秒'], why:'让身体记住正确的姿势，回到座位也能保持。', easy:'放慢速度。' },

  // 下肢
  { id:'shallow-split-squat', name:'分腿蹲', tag:'臀腿', cat:['lower'], sided:'换边',
    cues:['一只脚向前跨一大步，双脚不动','后脚跟抬起，身体向下沉','前膝不要超过脚尖，25 秒后换腿'], why:'单腿发力，练腿也练平衡。', easy:'扶着椅子，下得浅一点。' },

  // 拉
  { id:'hinge-reverse-fly', name:'俯身反向飞鸟', tag:'肩后侧 · 上背', cat:['pull'],
    cues:['从髋部向前俯身，手臂自然垂下','双臂向两侧打开，夹紧肩胛骨','慢慢放下；可以拿上哑铃加重'], why:'练肩后侧和上背，改善圆肩。', easy:'俯身角度小一点。' },

  // 拳击
  { id:'jab-cross-step', name:'刺拳直拳 + 转脚', tag:'拳击基础', cat:['box'],
    cues:['一只脚稍微在前，膝盖放松','先出前手，再转身出后手','后脚用前脚掌转动'], why:'学会用转身和脚发力出拳。', easy:'放慢速度，打准为主。' },
  { id:'standing-uppercuts', name:'站姿上勾拳', tag:'拳击 · 核心', cat:['box'],
    cues:['膝盖放松，双拳护在下巴前','一只拳从下往上打，身体稍微转动','左右手跟着节奏交替'], why:'练转体和上身力量。', easy:'放慢速度。' },
  { id:'boxer-shuffle', name:'拳击小碎步', tag:'步伐 · 心率', cat:['box'],
    cues:['膝盖放松，双拳护在下巴前','重心左右换脚，一次抬一只脚跟','步子小而轻，不跳'], why:'练拳击步伐，心率慢慢升高。', easy:'放慢节奏。' },
];
