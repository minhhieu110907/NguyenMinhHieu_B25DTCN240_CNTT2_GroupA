const container = document.getElementById("toast-container");

const messages = {
  success: "Thành công!",
  error: "Có lỗi xảy ra!",
  info: "Thông tin mới!",
  warning: "Cảnh báo!"
};

document.querySelectorAll(".btn").forEach(btn => {
  btn.addEventListener("click", () => {
    createToast(btn.dataset.type);
  });
});

function createToast(type) {
  const toast = document.createElement("div");
  toast.className = `toast ${type}`;
  toast.innerText = messages[type];

  container.appendChild(toast);

  // AUTO REMOVE
  setTimeout(() => {
    toast.style.animation = "fadeOut 0.5s forwards";

    setTimeout(() => {
      toast.remove();
    }, 500);
  }, 4000);
}