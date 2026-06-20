document.addEventListener('DOMContentLoaded', function() {
    console.log("Документ загружен, начинаем инициализацию...");

    const form = document.querySelector('.contact-form');
    const submitButton = form.querySelector('button[type="submit"]');

    form.addEventListener('submit', function(event) {
        event.preventDefault();

        document.querySelectorAll('.form-input.is-danger, .form-textarea.is-danger').forEach(input => {
            input.classList.remove('is-danger');
        });
        document.querySelectorAll('.help.is-danger').forEach(el => el.remove());

        let isValid = true;
        
        // Проверка полей Имя, Фамилия
        const nameFields = ['name', 'surname'];
        nameFields.forEach(id => {
            const input = form.querySelector(`#${id}`);
            if (input.value.trim() === '') {
                console.log(`Ошибка: поле ${id} пустое.`);
                showError(input, 'Это поле обязательно для заполнения');
                isValid = false;
            }
        });

        // Проверка Email
        const emailInput = form.querySelector('#email');
        const emailValue = emailInput.value.trim();
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (emailValue === '' || !emailPattern.test(emailValue)) {
            console.log("Ошибка: некорректный email.");
            showError(emailInput, 'Введите корректный адрес электронной почты');
            isValid = false;
        }

        // Проверка Тема
        const subjectInput = form.querySelector('#subject');
        if (subjectInput.value.trim() === '') {
            console.log("Ошибка: тема не указана.");
            showError(subjectInput, 'Тема обязательна для заполнения');
            isValid = false;
        }

        // Проверка Сообщения
        const messageTextarea = form.querySelector('#message');
        if (messageTextarea.value.trim() === '') {
            console.log("Ошибка: сообщение не указано.");
            showError(messageTextarea, 'Сообщение не может быть пустым');
            isValid = false;
        }
        else if (messageTextarea.value.trim().length < 10) {
            console.log("Ошибка: сообщение слишком короткое.");
            showError(messageTextarea, 'Сообщение должно содержать не менее 10 символов');
            isValid = false;
        }

        // Проверка чекбокса
        const consentCheckbox = form.querySelector('#consent');
        if (!consentCheckbox.checked) {
            console.log("Ошибка: чекбокс не отмечен.");
            showError(consentCheckbox, 'Вы должны согласиться с обработкой персональных данных');
            isValid = false;
        }

        if (isValid) {
            alert('Форма успешно отправлена!');
            console.clear();

            console.log('Имя:', form.querySelector('#name').value);
            console.log('Фамилия:', form.querySelector('#surname').value);
            console.log('Отчество:', form.querySelector('#patronymic').value);
            console.log('Email:', form.querySelector('#email').value);
            console.log('Тема:', form.querySelector('#subject').value);
            console.log('Сообщение:', form.querySelector('#message').value);
            
            const timestamp = new Date().toLocaleString();
            console.log('Время отправки:', timestamp);
        }
    });

    function showError(input, message) {
        input.classList.add('is-danger');
        const helpText = document.createElement('p');
        helpText.classList.add('help', 'is-danger');
        helpText.textContent = message;
        input.parentNode.appendChild(helpText);
    }
});