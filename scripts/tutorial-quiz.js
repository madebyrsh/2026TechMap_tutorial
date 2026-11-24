// Keep DocC's quiz behavior and translate the controls in the Korean lesson.
document.addEventListener("DOMContentLoaded", () => {
  const app = document.querySelector("#app");
  if (!app) return;

  const labels = new Map(Object.entries({
    "Check Your Understanding": "퀴즈",
    "Possible answers": "선택지",
    "Answer": "선택한 답:",
    "is correct": "정답",
    "is incorrect": "오답",
    "Submit": "정답 확인",
    "Next question": "다음 문제",
    "Next": "결과 보기",
    "Great job, you've answered all the questions for this tutorial.": "3문제를 모두 풀었어요."
  }));

  function translate() {
    const quiz = app.querySelector(".assessments-wrapper");
    if (!quiz) return;
    const targets = [
      quiz,
      ...app.querySelectorAll('a[href$="#Check-Your-Understanding"], .tutorials-navigation .toggle .text')
    ];
    for (const target of targets) {
      const walker = document.createTreeWalker(target, NodeFilter.SHOW_TEXT);
      for (let node = walker.nextNode(); node; node = walker.nextNode()) {
        const original = node.data.trim();
        const progress = original.match(/^Question (\d+) of (\d+)$/);
        const result = original.match(/^Answer (.+) is (correct|incorrect)$/);
        const replacement = labels.get(original) ??
          (progress ? `${progress[2]}문제 중 ${progress[1]}번` : null) ??
          (result ? `${result[1]}번: ${result[2] === "correct" ? "정답" : "오답"}` : null);
        if (replacement) node.data = node.data.replace(original, replacement);
      }
    }
  }

  new MutationObserver(translate).observe(app, {
    childList: true, subtree: true, characterData: true
  });
  translate();
});
